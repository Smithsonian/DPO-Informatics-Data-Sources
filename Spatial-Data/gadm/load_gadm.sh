#!/bin/bash
# 
# Convert GADM shapefiles to Postgres and write them to the database.
# Download the shapfiles before running script. 
# Currently: 
#    wget -nc -nd -r -np -l 1 -A zip https://geodata.ucdavis.edu/gadm/gadm4.1/shp/
# 
# v 2023-01-20 for GADM 4.1
#
# Rewrite for next release to simplify process

psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'gadm';"

script_date=$(date +'%Y-%m-%d')

#Store old tables
#echo "Backing up gadm0..."
#echo ""
#pg_dump -t gadm0 gis > gadm0_$script_date.dump.sql
#gzip gadm0_$script_date.dump.sql &
#
#echo "Backing up gadm1..."
#echo ""
#pg_dump -t gadm1 gis > gadm1_$script_date.dump.sql
#gzip gadm1_$script_date.dump.sql &
#
#echo "Backing up gadm2..."
#echo ""
#pg_dump -t gadm2 gis > gadm2_$script_date.dump.sql
#gzip gadm2_$script_date.dump.sql &
#
#echo "Backing up gadm3..."
#echo ""
#pg_dump -t gadm3 gis > gadm3_$script_date.dump.sql
#gzip gadm3_$script_date.dump.sql &
#
#echo "Backing up gadm4..."
#echo ""
#pg_dump -t gadm4 gis > gadm4_$script_date.dump.sql
#gzip gadm4_$script_date.dump.sql &
#
#echo "Backing up gadm5..."
#echo ""
#pg_dump -t gadm5 gis > gadm5_$script_date.dump.sql
#gzip gadm5_$script_date.dump.sql &

rm license.txt


psql -c "DROP VIEW IF EXISTS gadm;"
psql -c "DROP TABLE IF EXISTS gadm_alt_names CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm_types CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm0 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm1 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm2 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm3 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm4 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm5 CASCADE;"



# Create tables using France that has down to level 5
mkdir 1
mv gadm41_FRA_shp.zip 1/
cd 1
unzip gadm41_FRA_shp.zip
shp2pgsql -g the_geom gadm41_FRA_0.shp gadm0 > gadm0.sql
shp2pgsql -g the_geom gadm41_FRA_1.shp gadm1 > gadm1.sql
shp2pgsql -g the_geom gadm41_FRA_2.shp gadm2 > gadm2.sql
shp2pgsql -g the_geom gadm41_FRA_3.shp gadm3 > gadm3.sql
shp2pgsql -g the_geom gadm41_FRA_4.shp gadm4 > gadm4.sql
shp2pgsql -g the_geom gadm41_FRA_5.shp gadm5 > gadm5.sql

psql < gadm0.sql
psql < gadm1.sql
psql < gadm2.sql
psql < gadm3.sql
psql < gadm4.sql
psql < gadm5.sql

cd ../
rm -r 1


psql < varchars.sql


for zipfile in *.zip; do
	mkdir 1 
	cp $zipfile 1/
	cd 1/
	unzip $zipfile
		
	FILE=gadm41_*_0.shp
	if [ -f $FILE ]; then
		#level0
		shp2pgsql -a -g the_geom $FILE gadm0 > gadm.sql
		psql < gadm.sql
	fi
		
	FILE=gadm41_*_1.shp
	if [ -f $FILE ]; then
		#level0
		shp2pgsql -a -g the_geom $FILE gadm1 > gadm.sql
		psql < gadm.sql
	fi
		
	FILE=gadm41_*_2.shp
	if [ -f $FILE ]; then
		#level0
		shp2pgsql -a -g the_geom $FILE gadm2 > gadm.sql
		psql < gadm.sql
	fi
		
	FILE=gadm41_*_3.shp
	if [ -f $FILE ]; then
		#level0
		shp2pgsql -a -g the_geom $FILE gadm3 > gadm.sql
		psql < gadm.sql
	fi
		
	FILE=gadm41_*_4.shp
	if [ -f $FILE ]; then
		#level0
		shp2pgsql -a -g the_geom $FILE gadm4 > gadm.sql
		psql < gadm.sql
	fi
		
	FILE=gadm41_*_5.shp
	if [ -f $FILE ]; then
		#level0
		shp2pgsql -a -g the_geom $FILE gadm5 > gadm.sql
		psql < gadm.sql
	fi


	cd ..
	rm -r 1

done



# Copy to server

psql -c "DROP VIEW IF EXISTS gadm;"
psql -c "DROP TABLE IF EXISTS gadm_alt_names CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm_types CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm0 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm1 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm2 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm3 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm4 CASCADE;"
psql -c "DROP TABLE IF EXISTS gadm5 CASCADE;"


pg_dump --host localhost --encoding=utf8 --no-owner --username=gisuser -x -t gadm0 gis > gadm0.sql
pg_dump --host localhost --encoding=utf8 --no-owner --username=gisuser -x -t gadm1 gis > gadm1.sql
pg_dump --host localhost --encoding=utf8 --no-owner --username=gisuser -x -t gadm2 gis > gadm2.sql
pg_dump --host localhost --encoding=utf8 --no-owner --username=gisuser -x -t gadm3 gis > gadm3.sql
pg_dump --host localhost --encoding=utf8 --no-owner --username=gisuser -x -t gadm4 gis > gadm4.sql
pg_dump --host localhost --encoding=utf8 --no-owner --username=gisuser -x -t gadm5 gis > gadm5.sql

psql -f gadm0.sql
psql -f gadm1.sql
psql -f gadm2.sql
psql -f gadm3.sql
psql -f gadm4.sql
psql -f gadm5.sql




#Add indices and run data checks
psql < gadm_post.sql

psql -c "WITH data AS (SELECT count(*) as no_features FROM gadm) UPDATE data_sources SET no_features = data.no_features FROM data WHERE datasource_id = 'gadm';"

psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date' WHERE datasource_id = 'gadm';"

psql -c "UPDATE data_sources SET source_title = 'Database of Global Administrative Areas. v 4.1' WHERE datasource_id = 'gadm';"

