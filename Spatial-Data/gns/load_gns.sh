#!/bin/bash
#
# Update the gns table
#
# v 2022-09-29
#

script_date=$(date +'%Y-%m-%d')

#Download dataset from https://geonames.nga.mil/geonames/GNSData/
# Example:
#   wget --no-check-certificate https://geonames.nga.mil/geonames/GNSData/fc_files/Whole_World.7z
#   7za e Whole_World.7z

echo "Don't run automatically"
exit


#Remove first line
sed -i '1d' Whole_World.txt

#Store old tables
echo "Backing up GNS..."
echo ""
pg_dump -h localhost -U si_thesaurus -t gns si_thesaurus > gns_$script_date.dump.sql
gzip gns_$script_date.dump.sql &


#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'gns';"
psql -c "DROP TABLE IF EXISTS gns CASCADE;"

#Create table
psql < gns.sql

psql -c "WITH data AS (SELECT count(*) as no_features FROM gns) UPDATE data_sources SET no_features = data.no_features FROM data WHERE datasource_id = 'gns';"

psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date' WHERE datasource_id = 'gns';"
