#!/bin/bash
#
# Download shapefile from https://hub.arcgis.com/datasets/esri::usa-rivers-and-streams
#
#


# --
# INSERT INTO data_sources (
#     datasource_id,
#     source_title,
#     source_url,
#     source_notes,
#     source_date,
#     source_refresh
# )

# VALUES
#     (
#         'usa_rivers',
#         'USA Rivers and Streams',
#         'https://hub.arcgis.com/datasets/esri::usa-rivers-and-streams',
#         'This layer presents the linear water features (for example, aqueducts, canals, intracoastal waterways, and streams) of the United States. Credit: Esri, National Atlas of the United States, United States Geological Survey',
#         '2020-07-07',
#         'Every 12 months'
#     );

#Today's date
script_date=$(date +'%Y-%m-%d')

#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'usa_rivers';"


#Store old tables
echo "Backing up usa_rivers..."
echo ""
pg_dump -t usa_rivers > usa_rivers_$script_date.dump.sql
gzip usa_rivers_$script_date.dump.sql &

psql -c "DROP TABLE usa_rivers CASCADE;"

#Unzip file
unzip 0baca6c9ffd6499fb8e5fad50174c4e0_0.zip

#Convert shapefile to database
shp2pgsql -D -s 4326 -g the_geom 9ae73184-d43c-4ab8-940a-c8687f61952f2020328-1-r9gw71.0odx9.shp usa_rivers | psql -h localhost -U gisuser -d gis

#indices and new columns
psql < rivers_post.sql

psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from usa_rivers) w WHERE datasource_id = 'usa_rivers';"


#del files
rm 9ae73184-d43c-4ab8-940a-c8687f61952f2020328-1-r9gw71.0odx9.*
