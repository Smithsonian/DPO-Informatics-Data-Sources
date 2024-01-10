#!/bin/bash
#
# 2023-04-27
# 
# Get the OSM extracts from geofabrik.de and refresh the PostGIS database
#  using osm2pgsql (https://wiki.openstreetmap.org/wiki/Osm2pgsql)
# 
# This version uses the region-level files to reduce the resources
#  needed for oms2pgsql.
#


script_date=$(date +'%Y-%m-%d')


wget -i files.txt


#Columns to get the type
cols=(amenity barrier bridge building embankment harbour highway historic landuse leisure lock man_made military motorcar natural office place public_transport railway religion service shop sport surface toll tourism tunnel water waterway wetland wood)


mkdir done -p

#Download each file and load it to psql using osm2pgsql
for j in *.pbf; do
    echo ""
    echo "Working on file $j..."
    echo ""
    #Import pbf to postgres
    rm -f tmp/mycache.bin
    osm2pgsql --latlong --username osprey --host localhost --database osm -C 16000 --create --slim --number-processes 8 --multi-geometry --verbose --unlogged --flat-nodes tmp/mycache.bin $j

    #Execute for each column
    for i in ${cols[@]:0:6}; do
        #run separate script
        bash process_col.sh $i $j &
    done
    # wait for all columns to be done
    wait

    for i in ${cols[@]:6:6}; do
        #run separate script
        bash process_col.sh $i $j &
    done
    # wait for all columns to be done
    wait

    for i in ${cols[@]:12:6}; do
        #run separate script
        bash process_col.sh $i $j &
    done
    wait

    for i in ${cols[@]:18:6}; do
        #run separate script
        bash process_col.sh $i $j &
    done
    # wait for all columns to be done
    wait

    for i in ${cols[@]:24:6}; do
        #run separate script
        bash process_col.sh $i $j &
    done
    # wait for all columns to be done
    wait

mv $j done/
done

#Delete temp cache file
rm tmp/mycache.bin

#Cleanup
psql -c "DROP TABLE IF EXISTS planet_osm_line CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_nodes CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_point CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_polygon CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_rels CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_roads CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_ways CASCADE;"


#Move table between dbs
psql -c "DROP TABLE IF EXISTS osm_polygons CASCADE;"
pg_dump -t osm_polygons | psql -U gisuser -h localhost gis
psql -c "DROP TABLE IF EXISTS osm_polygons CASCADE;"


#Recreate indices
psql -c "CREATE INDEX osm_name_idx ON osm_polygons USING gin (name gin_trgm_ops);"
psql -c "CREATE INDEX osm_country_idx ON osm_polygons USING gin (country gin_trgm_ops);"
psql -c "CREATE INDEX osm_gadm2_idx ON osm_polygons USING gin (gadm2 gin_trgm_ops);"
psql -c "CREATE INDEX osm_thegeom_idx ON osm_polygons USING GIST(the_geom);"
psql -c "CREATE INDEX osm_thegeomw_idx ON osm_polygons USING GIST(the_geom_webmercator);"
psql -c "CREATE INDEX osm_centroid_idx ON osm_polygons USING GIST(centroid);"


#Turn datasource online
psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from osm_polygons) w WHERE datasource_id = 'osm';"
