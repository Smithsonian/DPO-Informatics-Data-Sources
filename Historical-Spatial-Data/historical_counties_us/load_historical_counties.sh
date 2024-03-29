#!/bin/bash
#
# Load the Atlas of Historical County Boundaries data
#
# v 2024-01-16
#

script_date=$(date +'%Y-%m-%d')

wget https://digital.newberry.org/ahcb/downloads/gis/US_AtlasHCB_Counties.zip
unzip US_AtlasHCB_Counties.zip
cd US_AtlasHCB_Counties/US_HistCounties_Shapefile/
shp2pgsql -g the_geom -s 4326 -D US_HistCounties.shp hist_counties > hist.sql


#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'hist_counties';"
psql -c "DROP TABLE IF EXISTS hist_counties CASCADE;"

#Create table
psql < hist.sql

psql -c "ALTER TABLE hist_counties ADD COLUMN uid uuid DEFAULT uuid_generate_v4();"
psql -c "
                CREATE INDEX hist_counties_st_idx ON hist_counties USING btree(state_terr);
                CREATE INDEX hist_counties_date1_idx ON hist_counties USING btree(start_date);
                CREATE INDEX hist_counties_date2_idx ON hist_counties USING btree(end_date);
                CREATE INDEX hist_counties_the_geom_idx ON hist_counties USING gist (the_geom);"



psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from hist_counties) w WHERE datasource_id = 'hist_counties';"
