#!/bin/bash
#
# 2021-02-04
#
#Get the OSM extracts from geofabrik.de and refresh the PostGIS database
# using osm2pgsql (https://wiki.openstreetmap.org/wiki/Osm2pgsql)
# 

#Delete unused tables
psql -c "DROP TABLE IF EXISTS planet_osm_line CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_nodes CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_point CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_rels CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_roads CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_polygon CASCADE;"
psql -c "DROP TABLE IF EXISTS planet_osm_ways CASCADE;"

psql < table.sql

#Turn datasource offline
psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'osm';"

#Drop indices before bulk loading
psql -c "DROP INDEX IF EXISTS osm_name_idx;"
psql -c "DROP INDEX IF EXISTS osm_thegeom_idx;"
psql -c "DROP INDEX IF EXISTS osm_thegeomw_idx;"
psql -c "DROP INDEX IF EXISTS osm_centroid_idx;"


psql < table.sql


#pg_dump --table="gadm2" -x > gadm2.sql
#psql -c "DROP TABLE IF EXISTS gadm2 CASCADE;"
#psql < gadm2.sql
