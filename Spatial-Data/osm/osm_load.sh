#!/bin/bash
#
# 2021-02-09
# 
# Get the OSM extracts from geofabrik.de and refresh the PostGIS database
#  using osm2pgsql (https://wiki.openstreetmap.org/wiki/Osm2pgsql)
# 
# This version uses the region-level files to reduce the resources
#  needed for oms2pgsql.
#


script_date=$(date +'%Y-%m-%d')


# wget https://download.geofabrik.de/africa-latest.osm.pbf

# wget https://download.geofabrik.de/antarctica-latest.osm.pbf
# wget https://download.geofabrik.de/asia-latest.osm.pbf
# wget https://download.geofabrik.de/australia-oceania-latest.osm.pbf
# wget https://download.geofabrik.de/central-america-latest.osm.pbf
# wget https://download.geofabrik.de/europe-latest.osm.pbf
# wget https://download.geofabrik.de/north-america-latest.osm.pbf
# wget https://download.geofabrik.de/south-america-latest.osm.pbf


#Columns to get the type
cols=(amenity barrier bridge building embankment harbour highway historic landuse leisure lock man_made military motorcar natural office place public_transport railway religion service shop sport surface toll tourism tunnel water waterway wetland wood)


mkdir done -p

#Download each file and load it to psql using osm2pgsql
for j in *.pbf; do
    echo ""
    echo "Working on file $j..."
    echo ""
    #Import pbf to postgres
    rm /mnt/fastdisk/tmp/mycache.bin
    osm2pgsql --latlong --username gisuser --host localhost --database osm -C 16000 --create --slim --number-processes 8 --multi-geometry --verbose --unlogged --flat-nodes /mnt/fastdisk/tmp/mycache.bin $j

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
rm /mnt/fastdisk/tmp/mycache.bin

#Cleanup
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_line CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_nodes CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_point CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_polygon CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_rels CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_roads CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_ways CASCADE;"


#Move table between dbs
psql -U gisuser -h localhost gis -c "DROP TABLE IF EXISTS osm_polygons CASCADE;"
pg_dump -U gisuser -h localhost -t osm_polygons osm | psql -U gisuser -h localhost gis
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS osm_polygons CASCADE;"


#Recreate indices
psql -U gisuser -h localhost gis -c "CREATE INDEX osm_name_idx ON osm_polygons USING gin (name gin_trgm_ops);"
psql -U gisuser -h localhost gis -c "CREATE INDEX osm_country_idx ON osm_polygons USING gin (country gin_trgm_ops);"
psql -U gisuser -h localhost gis -c "CREATE INDEX osm_gadm2_idx ON osm_polygons USING gin (gadm2 gin_trgm_ops);"
psql -U gisuser -h localhost gis -c "CREATE INDEX osm_thegeom_idx ON osm_polygons USING GIST(the_geom);"
psql -U gisuser -h localhost gis -c "CREATE INDEX osm_thegeomw_idx ON osm_polygons USING GIST(the_geom_webmercator);"
psql -U gisuser -h localhost gis -c "CREATE INDEX osm_centroid_idx ON osm_polygons USING GIST(centroid);"


#Turn datasource online
psql -U gisuser -h localhost gis -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from osm_polygons) w WHERE datasource_id = 'osm';"

