--CREATE EXTENSION IF NOT EXISTS hstore;
--CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- Allow to search for accents and diacritics
CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE TEXT SEARCH CONFIGURATION mydict ( COPY = simple );
ALTER TEXT SEARCH CONFIGURATION mydict
  ALTER MAPPING FOR hword, hword_part, word
  WITH unaccent, simple;
  
  
DROP TABLE IF EXISTS osm;
DROP TABLE IF EXISTS osm_polygons;
DROP TABLE IF EXISTS osm_points;

CREATE TABLE osm_polygons (
    uid uuid DEFAULT uuid_generate_v4(),
    source_id text,
    name text,
    type text,
    centroid geometry('Point', 4326),
    attributes hstore,
    data_source text,
    gadm2 text,
    country text,
    the_geom geometry('Multipolygon', 4326),
    the_geom_webmercator geometry('Multipolygon', 3857)
);

--
-- CREATE TABLE osm_points (
--     uid uuid DEFAULT uuid_generate_v4(),
--     source_id text,
--     name text,
--     type text,
--     attributes hstore,
--     data_source text,
--     gadm2 text,
--     country text,
--     the_geom geometry('Point', 4326),
--     the_geom_webmercator geometry('Point', 3857)
-- );
