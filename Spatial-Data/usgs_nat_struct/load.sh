#!/bin/bash
#
# USGS National Structures Dataset
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
#         'usgs_nat_struct',
#         'USGS National Structures Dataset',
#         'http://nationalmap.usgs.gov',
#         'Features of this dataset are various private and public man-made structures and installations.',
#         '2020-07-08',
#         'Every 12 months'
#     );

#Today's date
script_date=$(date +'%Y-%m-%d')

#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'usgs_nat_struct';"


#Store old tables
echo "Backing up usgs_nat_struct..."
echo ""
pg_dump -t usgs_nat_struct > usgs_nat_struct_$script_date.dump.sql
gzip usgs_nat_struct_$script_date.dump.sql &

psql -c "DROP TABLE usgs_nat_struct CASCADE;"



#Convert shapefile to database
shp2pgsql -D -g the_geom Structures_National.shp usgs_nat_struct | psql

#indices and new columns
psql < post.sql

psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from usgs_nat_struct) w WHERE datasource_id = 'usgs_nat_struct';"
