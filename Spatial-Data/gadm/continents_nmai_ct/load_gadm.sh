#!/bin/bash
# 
# Load continent shapefile for the NMAI CT based on gadm level0
# 
# v 2021-11-16
#

#load
psql -c "DROP TABLE IF EXISTS gadm_continents_nmai_ct CASCADE;"
shp2pgsql -g the_geom -D gadm_continents.shp gadm_continents_nmai_ct > gadm_continents_nmai_ct.sql
psql < gadm_continents_nmai_ct.sql
rm gadm_continents_nmai_ct.sql

#Add indices and run data checks
psql < post.sql
