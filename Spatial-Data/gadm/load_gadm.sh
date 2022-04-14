#!/bin/bash
# 
# Convert GADM shapefiles to Postgres and write them to the database.
# Download the lelevs shapfile and unzip before running script. 
# Currently: 
#    wget https://geodata.ucdavis.edu/gadm/gadm4.0/gadm404-shp.zip
# 
# Prefix: gadm40
# 
# v 2022-03-24 for GADM 4.0.4
#

psql -U gisuser -h localhost gis -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'gadm';"

script_date=$(date +'%Y-%m-%d')

#Store old tables
#echo "Backing up gadm0..."
#echo ""
#pg_dump -h localhost -U gisuser -t gadm0 gis > gadm0_$script_date.dump.sql
#gzip gadm0_$script_date.dump.sql &
#
#echo "Backing up gadm1..."
#echo ""
#pg_dump -h localhost -U gisuser -t gadm1 gis > gadm1_$script_date.dump.sql
#gzip gadm1_$script_date.dump.sql &
#
#echo "Backing up gadm2..."
#echo ""
#pg_dump -h localhost -U gisuser -t gadm2 gis > gadm2_$script_date.dump.sql
#gzip gadm2_$script_date.dump.sql &
#
#echo "Backing up gadm3..."
#echo ""
#pg_dump -h localhost -U gisuser -t gadm3 gis > gadm3_$script_date.dump.sql
#gzip gadm3_$script_date.dump.sql &
#
#echo "Backing up gadm4..."
#echo ""
#pg_dump -h localhost -U gisuser -t gadm4 gis > gadm4_$script_date.dump.sql
#gzip gadm4_$script_date.dump.sql &
#
#echo "Backing up gadm5..."
#echo ""
#pg_dump -h localhost -U gisuser -t gadm5 gis > gadm5_$script_date.dump.sql
#gzip gadm5_$script_date.dump.sql &

rm license.txt

#All in a single file

psql -U gisuser -h localhost -p 5432 gis -c "DROP TABLE IF EXISTS gadm0 CASCADE;"
psql -U gisuser -h localhost -p 5432 gis -c "DROP TABLE IF EXISTS gadm1 CASCADE;"
psql -U gisuser -h localhost -p 5432 gis -c "DROP TABLE IF EXISTS gadm2 CASCADE;"
psql -U gisuser -h localhost -p 5432 gis -c "DROP TABLE IF EXISTS gadm3 CASCADE;"
psql -U gisuser -h localhost -p 5432 gis -c "DROP TABLE IF EXISTS gadm4 CASCADE;"
psql -U gisuser -h localhost -p 5432 gis -c "DROP TABLE IF EXISTS gadm5 CASCADE;"
psql -U gisuser -h localhost -p 5432 gis -c "DROP VIEW IF EXISTS gadm;"



#level1
shp2pgsql -g the_geom -D gadm404_level1.shp gadm1 > gadm1.sql
psql -U gisuser -h localhost -p 5432 gis < gadm1.sql
rm gadm1.sql


#level2
shp2pgsql -g the_geom -D gadm404_level2.shp gadm2 > gadm2.sql
psql -U gisuser -h localhost -p 5432 gis < gadm2.sql
rm gadm2.sql


#level3
shp2pgsql -g the_geom -D gadm404_level3.shp gadm3 > gadm3.sql
psql -U gisuser -h localhost -p 5432 gis < gadm3.sql
rm gadm3.sql


#level4
shp2pgsql -g the_geom -D gadm404_level4.shp gadm4 > gadm4.sql
psql -U gisuser -h localhost -p 5432 gis < gadm4.sql
rm gadm4.sql


#level5
shp2pgsql -g the_geom -D gadm404_level5.shp gadm5 > gadm5.sql
psql -U gisuser -h localhost -p 5432 gis < gadm5.sql
rm gadm5.sql






#Add indices and run data checks
psql -U gisuser -h localhost -p 5432 gis < gadm_post.sql

psql -U gisuser -h localhost gis -c "WITH data AS (SELECT count(*) as no_features FROM gadm) UPDATE data_sources SET no_features = data.no_features FROM data WHERE datasource_id = 'gadm';"

psql -U gisuser -h localhost gis -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date' WHERE datasource_id = 'gadm';"
