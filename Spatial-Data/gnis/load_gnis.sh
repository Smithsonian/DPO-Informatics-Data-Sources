#!/bin/bash

#Today's date
script_date=$(date +'%Y-%m-%d')

#Download dump from 
#  https://www.usgs.gov/us-board-on-geographic-names/download-gnis-data

unzip DomesticNames_National_Text.zip

#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'gnis';"


#Store old tables
echo "Backing up gnis..."
echo ""
pg_dump -t gnis > gnis_$script_date.dump.sql
gzip gnis_$script_date.dump.sql &

psql -c "DROP TABLE IF EXISTS gnis CASCADE;"

#Create table
psql -c "CREATE TABLE gnis (
    feature_id	int,
    feature_name	text,
    feature_class	text,
    state_name	text,
    state_numeric	text,
    county_name	text,
    county_numeric	text,
    map_name	text,
    date_created	text,
    date_edited	text,
    bgn_type	text,
    bgn_authority	text,
    bgn_date	text,
    prim_lat_dms	text,
    prim_long_dms	text,
    prim_lat_dec	float,
    prim_long_dec	float,
    source_lat_dms	text,
    source_long_dms	text,
    source_lat_dec	text,
    source_long_dec	text
    );"


datafile='Text/DomesticNames_National.txt'

psql -c "\copy gnis from '$datafile' DELIMITER '|' CSV HEADER;"

psql < gnis_post.sql

psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from gnis) w WHERE datasource_id = 'gnis';"

rm DomesticNames_National_Text.*
rm -r Text
