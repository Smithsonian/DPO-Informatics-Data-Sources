#!/bin/bash

# Today's date
script_date=$(date +'%Y-%m-%d')

# Download data index
#  Referenced from https://www.usgs.gov/the-national-map-data-delivery/topographic-maps
wget https://prd-tnm.s3.amazonaws.com/StagedProducts/Maps/Metadata/historicaltopo.zip

unzip historicaltopo.zip

psql [database] < table_load.sql


wget download.txt
