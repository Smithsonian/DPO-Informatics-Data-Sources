#!/bin/bash
#
# 2021-02-04
#
#Get the OSM extracts from geofabrik.de and refresh the PostGIS database
# using osm2pgsql (https://wiki.openstreetmap.org/wiki/Osm2pgsql)
# 


#Delete unused tables
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_line CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_nodes CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_point CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_rels CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_roads CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_polygon CASCADE;"
psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS planet_osm_ways CASCADE;"

psql -U gisuser -h localhost osm < table.sql

#Turn datasource offline
psql -U gisuser -h localhost gis -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'osm';"

#Drop indices before bulk loading
psql -U gisuser -h localhost gis -c "DROP INDEX IF EXISTS osm_name_idx;"
psql -U gisuser -h localhost gis -c "DROP INDEX IF EXISTS osm_thegeom_idx;"
psql -U gisuser -h localhost gis -c "DROP INDEX IF EXISTS osm_thegeomw_idx;"
psql -U gisuser -h localhost gis -c "DROP INDEX IF EXISTS osm_centroid_idx;"


psql -U gisuser -h localhost gis < table.sql


pg_dump -U gisuser -h localhost --table="gadm2" -x gis > gadm2.sql

psql -U gisuser -h localhost osm -c "DROP TABLE IF EXISTS gadm2 CASCADE;"

psql -U gisuser -h localhost osm < gadm2.sql
