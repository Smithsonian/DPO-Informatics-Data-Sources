#!/bin/bash
#

#Today's date
script_date=$(date +'%Y-%m-%d')

#Tiger folders

#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'tiger';"


# AREALM
#2019 TIGER/Line Shapefile Area Landmark State-based Shapefile
wget -r -l1 -t1 -nd -N -np -A.zip -erobots=off https://www2.census.gov/geo/tiger/TIGER2021/AREALM/

#Empty table
psql -c "TRUNCATE tiger_arealm;"
psql -c "VACUUM tiger_arealm;"

#Download each file and load it to psql using osm2pgsql
for zipfile in *.zip; do
    echo ""
    echo "Working on file $zipfile..."
    echo ""

    unzip $zipfile

    shp2pgsql -a -g the_geom -D ${zipfile%.zip}.shp tiger_arealm > tiger_arealm.sql

    psql < tiger_arealm.sql

    rm tiger_arealm.sql
    rm ${zipfile%.zip}.cpg
    rm ${zipfile%.zip}.dbf
    rm ${zipfile%.zip}.prj
    rm ${zipfile%.zip}*.xml
    rm ${zipfile%.zip}.shx
    rm ${zipfile%.zip}.shp

done

psql -c "DELETE FROM tiger_arealm WHERE fullname IS NULL;"





# AREAWATER
#2019 TIGER/Line Shapefile Area Hydrography County-based Shapefile
#cd AREAWATER

wget -r -l1 -t1 -nd -N -np -A.zip -erobots=off https://www2.census.gov/geo/tiger/TIGER2021/AREAWATER/

#Empty table
psql -c "TRUNCATE tiger_areawater;"
psql -c "VACUUM tiger_areawater;"


#nested zips
for zipfile in *.zip; do
    echo ""
    echo "Working on file $zipfile..."
    echo ""

    unzip -o $zipfile
    #rm $zipfile
done



for shapefile in *.shp; do
    echo ""
    echo "Working on file $shapefile..."
    echo ""

    shp2pgsql -a -g the_geom -D $shapefile tiger_areawater > tiger_areawater.sql
    psql < tiger_areawater.sql
    rm tiger_areawater.sql
done


psql -c "DELETE FROM tiger_areawater WHERE fullname IS NULL;"




# COUNTY
#2019 TIGER Current County and Equivalent National Shapefile
#cd AREALM
wget -r -l1 -t1 -nd -N -np -A.zip -erobots=off https://www2.census.gov/geo/tiger/TIGER2021/AREALM/

#Empty table
psql -c "TRUNCATE tiger_counties;"
psql -c "VACUUM tiger_counties;"

#Download each file and load it to psql using osm2pgsql

for zipfile in *.zip; do
    echo ""
    echo "Working on file $zipfile..."
    echo ""

    unzip -o $zipfile
    #rm $zipfile
done



for shapefile in *.shp; do
    echo ""
    echo "Working on file $shapefile..."
    echo ""

    shp2pgsql -a -g the_geom -D $shapefile tiger_counties > county.sql
    psql < county.sql
    rm county.sql
done







# ROADS
#2019 TIGER All Roads County-based Shapefile
cd ROADS

#Empty table
psql -c "TRUNCATE tiger_roads;"
psql -c "VACUUM tiger_roads;"


#unzip files
for zipfile in *.zip; do
    echo ""
    echo "Working on file $zipfile..."
    echo ""

    unzip -o $zipfile
    rm $zipfile
done


for shapefile in *.shp; do
    echo ""
    echo "Working on file $shapefile..."
    echo ""

    shp2pgsql -a -g the_geom -D $shapefile tiger_roads > tiger_roads.sql

    psql < tiger_roads.sql

    rm tiger_roads.sql

done

psql -c "DELETE FROM tiger_roads WHERE fullname IS NULL;"

psql < post_insert.sql




#Turn datasource online
psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w1.no_feats FROM (SELECT sum(w.no_feats) AS no_feats FROM (select count(*) as no_feats from tiger_roads UNION select count(*) as no_feats from tiger_counties UNION select count(*) as no_feats from tiger_areawater UNION select count(*) as no_feats from tiger_arealm) w) w1 WHERE datasource_id = 'tiger';"
