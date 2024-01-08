#!/bin/bash
#
# Load the CShapes Dataset
# CShapes 2.0 maps the borders and capitals of independent states
#   and dependent territories from 1886 to 2019. There are two
#   versions of the dataset, which are based on the Gleditsch
#   and Ward (1999) or the Correlates of War coding of independent
#   states. Border changes were coded based on the Territorial
#   Change Dataset by Tir et al (1998), the Encyclopedia of
#   International Boundaries by Biger (1995) and the Encyclopedia
#   of African Boundaries by Brownlie (1979).
#
# v 2022-09-29
#

script_date=$(date +'%Y-%m-%d')

# https://icr.ethz.ch/data/cshapes/

shp2pgsql -W LATIN1 -g the_geom -s 4326 -D CShapes-2.0.shp cshapes2 > cshapes.sql


#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'cshapes';"
psql -c "DROP TABLE IF EXISTS cshapes2 CASCADE;"

#Create table
psql < cshapes.sql

psql -c "UPDATE cshapes2 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'f';"

psql -c "ALTER TABLE cshapes2 ADD COLUMN uid uuid DEFAULT uuid_generate_v4();"

psql -c "ALTER TABLE cshapes2 ADD COLUMN start_date date;"
psql -c "ALTER TABLE cshapes2 ADD COLUMN end_date date;"

psql -c "UPDATE cshapes2 SET start_date = gwsdate::date;"
psql -c "UPDATE cshapes2 SET end_date = gwedate::date;"

psql -c "
                CREATE INDEX cshapes_cname_idx ON cshapes2 USING btree(cntry_name);
                CREATE INDEX cshapes_uid_idx ON cshapes2 USING btree(uid);
                CREATE INDEX cshapes_date1_idx ON cshapes2 USING btree(start_date);
                CREATE INDEX cshapes_date2_idx ON cshapes2 USING btree(end_date);
                CREATE INDEX cshapes_the_geom_idx ON cshapes2 USING gist(the_geom);"


psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', no_features = w.no_feats FROM (select count(*) as no_feats from cshapes2) w WHERE datasource_id = 'cshapes';"
