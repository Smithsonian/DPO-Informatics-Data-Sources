#!/bin/bash
#
# Download shapefiles from https://www.protectedplanet.net/
#
# wget -O wdpa.zip https://www.protectedplanet.net/downloads/WDPA_[DATE]?type=shapefile
#

#Today's date
script_date=$(date +'%Y-%m-%d')

#unzip wdpa.zip

wget https://d1gam3xoknrgr2.cloudfront.net/current/WDPA_Jan2024_Public_shp.zip

mkdir 0
mkdir 1
mkdir 2

mv WDPA_Jan2024_Public_shp_0.zip 0/
mv WDPA_Jan2024_Public_shp_1.zip 1/
mv WDPA_Jan2024_Public_shp_2.zip 2/

cd 0
unzip WDPA_Jan2024_Public_shp_0.zip
cd ../1
unzip WDPA_Jan2024_Public_shp_1.zip
cd ../2
unzip WDPA_Jan2024_Public_shp_2.zip
cd ..


#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'wdpa_polygons';"
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'wdpa_points';"


#Store old tables
echo "Backing up wdpa_points..."
echo ""
pg_dump -t wdpa_points si_thesaurus > wdpa_points_$script_date.dump.sql
gzip wdpa_points_$script_date.dump.sql

echo "Backing up wdpa_polygons..."
echo ""
pg_dump -t wdpa_polygons si_thesaurus > wdpa_polygons_$script_date.dump.sql
gzip wdpa_polygons_$script_date.dump.sql

psql -c "DROP TABLE wdpa_points CASCADE;"
psql -c "DROP TABLE wdpa_polygons CASCADE;"

#Convert shapefiles to Postsi_thesaurus format
pointshp=`ls 0/WDPA*-points.shp`
shp2pgsql -s 4326 -g the_geom -D $pointshp wdpa_points > wdpa_points.sql
polyshp=`ls 0/WDPA*-polygons.shp`
shp2pgsql -s 4326 -g the_geom -D $polyshp wdpa_polygons > wdpa_polygons.sql
#Load Postsi_thesaurus files to database
psql < wdpa_points.sql
psql < wdpa_polygons.sql
rm wdpa_points.sql
rm wdpa_polygons.sql

pointshp=`ls 1/WDPA*-points.shp`
shp2pgsql -s 4326 -g the_geom -D -a $pointshp wdpa_points > wdpa_points.sql
polyshp=`ls 1/WDPA*-polygons.shp`
shp2pgsql -s 4326 -g the_geom -D -a $polyshp wdpa_polygons > wdpa_polygons.sql
#Load Postsi_thesaurus files to database
psql < wdpa_points.sql
psql < wdpa_polygons.sql
rm wdpa_points.sql
rm wdpa_polygons.sql

pointshp=`ls 2/WDPA*-points.shp`
shp2pgsql -s 4326 -g the_geom -D -a $pointshp wdpa_points > wdpa_points.sql
polyshp=`ls 2/WDPA*-polygons.shp`
shp2pgsql -s 4326 -g the_geom -D -a $polyshp wdpa_polygons > wdpa_polygons.sql
#Load Postsi_thesaurus files to database
psql < wdpa_points.sql
psql < wdpa_polygons.sql
rm wdpa_points.sql
rm wdpa_polygons.sql



#indices and new columns
psql < wdpa_post.sql

psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from wdpa_polygons) w WHERE datasource_id = 'wdpa_polygons';"
psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from wdpa_points) w WHERE datasource_id = 'wdpa_points';"



#del files
rm wdpa.zip
rm -r Res*
rm -r Recursos*
rm -r 0
rm -r 1
rm -r 2
