
--Make sure all the geoms are multipolygons and that they are valid
UPDATE gadm0 SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm0 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';
UPDATE gadm1 SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm1 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';
UPDATE gadm2 SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm2 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';
UPDATE gadm3 SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm3 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';
UPDATE gadm4 SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm4 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';
UPDATE gadm5 SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm5 SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';


-- Add name_0
ALTER TABLE gadm0 ADD COLUMN name_0 text;
UPDATE gadm0 SET name_0 = country;
ALTER TABLE gadm1 ADD COLUMN name_0 text;
UPDATE gadm1 SET name_0 = country;
ALTER TABLE gadm2 ADD COLUMN name_0 text;
UPDATE gadm2 SET name_0 = country;
ALTER TABLE gadm3 ADD COLUMN name_0 text;
UPDATE gadm3 SET name_0 = country;
ALTER TABLE gadm4 ADD COLUMN name_0 text;
UPDATE gadm4 SET name_0 = country;
ALTER TABLE gadm5 ADD COLUMN name_0 text;
UPDATE gadm5 SET name_0 = country;



-- Allow to search for accents and diacritics
CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE TEXT SEARCH CONFIGURATION mydict ( COPY = simple );
ALTER TEXT SEARCH CONFIGURATION mydict
  ALTER MAPPING FOR hword, hword_part, word
  WITH unaccent, simple;

CREATE INDEX ON gadm0 USING GIST (to_tsvector('mydict', name_0));
CREATE INDEX ON gadm1 USING GIST (to_tsvector('mydict', name_1));
CREATE INDEX ON gadm2 USING GIST (to_tsvector('mydict', name_2));
CREATE INDEX ON gadm3 USING GIST (to_tsvector('mydict', name_3));
CREATE INDEX ON gadm4 USING GIST (to_tsvector('mydict', name_4));
CREATE INDEX ON gadm5 USING GIST (to_tsvector('mydict', name_5));

CREATE INDEX gadm0_name0_idx ON gadm0 USING BTREE(name_0);
CREATE INDEX gadm0_name1_idx ON gadm1 USING BTREE(name_1);
CREATE INDEX gadm0_name2_idx ON gadm2 USING BTREE(name_2);
CREATE INDEX gadm0_name3_idx ON gadm3 USING BTREE(name_3);
CREATE INDEX gadm0_name4_idx ON gadm4 USING BTREE(name_4);
CREATE INDEX gadm0_name5_idx ON gadm5 USING BTREE(name_5);


-- gadm0
ALTER TABLE gadm0 ADD COLUMN iso3 text;
UPDATE gadm0 SET iso3 = gid_0;

ALTER TABLE gadm0 ADD COLUMN engtype_0 text;
UPDATE gadm0 SET engtype_0 = 'country';
CREATE INDEX gadm0_type_idx ON gadm0 USING BTREE(engtype_0);
CREATE INDEX gadm0_name0_trgm_idx ON gadm0 USING gin (name_0 gin_trgm_ops);
--Issues with Antarctica at the edge of (180 90), clip just inside
UPDATE gadm0 SET the_geom = ST_INTERSECTION(the_geom, ST_SETSRID(ST_GeomFromText('POLYGON((-179.999999 -89.999999, 179.999999 -89.999999, 179.999999 89.999999, -179.999999 89.999999, -179.999999 -89.999999))'), 4326)) WHERE name_0 = 'Antarctica';
CREATE INDEX gadm0_the_geom_idx ON gadm0 USING gist (the_geom);

-- gadm1
CREATE INDEX gadm1_type_idx ON gadm1 USING BTREE(engtype_1);
CREATE INDEX gadm1_name0_trgm_idx ON gadm1 USING gin (name_0 gin_trgm_ops);
CREATE INDEX gadm1_name1_trgm_idx ON gadm1 USING gin (name_1 gin_trgm_ops);
CREATE INDEX gadm1_the_geom_idx ON gadm1 USING gist (the_geom);

-- gadm2
CREATE INDEX gadm2_type_idx ON gadm2 USING BTREE(engtype_2);
CREATE INDEX gadm2_name0_trgm_idx ON gadm2 USING gin (name_0 gin_trgm_ops);
CREATE INDEX gadm2_name1_trgm_idx ON gadm2 USING gin (name_1 gin_trgm_ops);
CREATE INDEX gadm2_name2_trgm_idx ON gadm2 USING gin (name_2 gin_trgm_ops);
CREATE INDEX gadm2_the_geom_idx ON gadm2 USING gist (the_geom);

-- gadm3
CREATE INDEX gadm3_type_idx ON gadm3 USING BTREE(engtype_3);
CREATE INDEX gadm3_name0_trgm_idx ON gadm3 USING gin (name_0 gin_trgm_ops);
CREATE INDEX gadm3_name1_trgm_idx ON gadm3 USING gin (name_1 gin_trgm_ops);
CREATE INDEX gadm3_name2_trgm_idx ON gadm3 USING gin (name_2 gin_trgm_ops);
CREATE INDEX gadm3_name3_trgm_idx ON gadm3 USING gin (name_3 gin_trgm_ops);
CREATE INDEX gadm3_the_geom_idx ON gadm3 USING gist (the_geom);

-- gadm4
CREATE INDEX gadm4_type_idx ON gadm4 USING BTREE(engtype_4);
CREATE INDEX gadm4_name0_trgm_idx ON gadm4 USING gin (name_0 gin_trgm_ops);
CREATE INDEX gadm4_name1_trgm_idx ON gadm4 USING gin (name_1 gin_trgm_ops);
CREATE INDEX gadm4_name2_trgm_idx ON gadm4 USING gin (name_2 gin_trgm_ops);
CREATE INDEX gadm4_name3_trgm_idx ON gadm4 USING gin (name_3 gin_trgm_ops);
CREATE INDEX gadm4_name4_trgm_idx ON gadm4 USING gin (name_4 gin_trgm_ops);
CREATE INDEX gadm4_the_geom_idx ON gadm4 USING gist (the_geom);

-- gadm5
CREATE INDEX gadm5_type_idx ON gadm5 USING BTREE(engtype_5);
CREATE INDEX gadm5_name0_trgm_idx ON gadm5 USING gin (name_0 gin_trgm_ops);
CREATE INDEX gadm5_name1_trgm_idx ON gadm5 USING gin (name_1 gin_trgm_ops);
CREATE INDEX gadm5_name2_trgm_idx ON gadm5 USING gin (name_2 gin_trgm_ops);
CREATE INDEX gadm5_name3_trgm_idx ON gadm5 USING gin (name_3 gin_trgm_ops);
CREATE INDEX gadm5_name4_trgm_idx ON gadm5 USING gin (name_4 gin_trgm_ops);
CREATE INDEX gadm5_name5_trgm_idx ON gadm5 USING gin (name_5 gin_trgm_ops);
CREATE INDEX gadm5_the_geom_idx ON gadm5 USING gist (the_geom);

--Add unique IDs
alter table gadm0 add column uid uuid DEFAULT uuid_generate_v4();
alter table gadm1 add column uid uuid DEFAULT uuid_generate_v4();
alter table gadm2 add column uid uuid DEFAULT uuid_generate_v4();
alter table gadm3 add column uid uuid DEFAULT uuid_generate_v4();
alter table gadm4 add column uid uuid DEFAULT uuid_generate_v4();
alter table gadm5 add column uid uuid DEFAULT uuid_generate_v4();

CREATE INDEX gadm0_uid_idx ON gadm0 USING btree (uid);
CREATE INDEX gadm1_uid_idx ON gadm1 USING btree (uid);
CREATE INDEX gadm2_uid_idx ON gadm2 USING btree (uid);
CREATE INDEX gadm3_uid_idx ON gadm3 USING btree (uid);
CREATE INDEX gadm4_uid_idx ON gadm4 USING btree (uid);
CREATE INDEX gadm5_uid_idx ON gadm5 USING btree (uid);


--Simplified geoms
ALTER TABLE gadm0 ADD COLUMN the_geom_simp geometry(MultiPolygon, 4326);
UPDATE gadm0 SET the_geom_simp = st_multi(st_collectionextract(ST_MAKEVALID(ST_SIMPLIFY(the_geom, 0.001)),3));

ALTER TABLE gadm1 ADD COLUMN the_geom_simp geometry(MultiPolygon, 4326);
UPDATE gadm1 SET the_geom_simp = st_multi(st_collectionextract(ST_MAKEVALID(ST_SIMPLIFY(the_geom, 0.001)),3));

ALTER TABLE gadm2 ADD COLUMN the_geom_simp geometry(MultiPolygon, 4326);
UPDATE gadm2 SET the_geom_simp = st_multi(st_collectionextract(ST_MAKEVALID(ST_SIMPLIFY(the_geom, 0.001)),3));

ALTER TABLE gadm3 ADD COLUMN the_geom_simp geometry(MultiPolygon, 4326);
UPDATE gadm3 SET the_geom_simp = st_multi(st_collectionextract(ST_MAKEVALID(ST_SIMPLIFY(the_geom, 0.001)),3));

ALTER TABLE gadm4 ADD COLUMN the_geom_simp geometry(MultiPolygon, 4326);
UPDATE gadm4 SET the_geom_simp = st_multi(st_collectionextract(ST_MAKEVALID(ST_SIMPLIFY(the_geom, 0.001)),3));

ALTER TABLE gadm5 ADD COLUMN the_geom_simp geometry(MultiPolygon, 4326);
UPDATE gadm5 SET the_geom_simp = st_multi(st_collectionextract(ST_MAKEVALID(ST_SIMPLIFY(the_geom, 0.001)),3));


CREATE INDEX gadm0_the_geom_simp_idx ON gadm0 USING GIST(the_geom_simp);
CREATE INDEX gadm1_the_geom_simp_idx ON gadm1 USING GIST(the_geom_simp);
CREATE INDEX gadm2_the_geom_simp_idx ON gadm2 USING GIST(the_geom_simp);
CREATE INDEX gadm3_the_geom_simp_idx ON gadm3 USING GIST(the_geom_simp);
CREATE INDEX gadm4_the_geom_simp_idx ON gadm4 USING GIST(the_geom_simp);
CREATE INDEX gadm5_the_geom_simp_idx ON gadm5 USING GIST(the_geom_simp);



--Add geom_webmercator
ALTER TABLE gadm0 ADD COLUMN the_geom_webmercator geometry(MultiPolygon, 3857);
UPDATE gadm0 SET the_geom_webmercator = st_multi(ST_MAKEVALID(st_transform(the_geom, 3857)));
CREATE INDEX gadm0_tgeomw_idx ON gadm0 USING GIST(the_geom_webmercator);

ALTER TABLE gadm1 ADD COLUMN the_geom_webmercator geometry(MultiPolygon, 3857);
UPDATE gadm1 SET the_geom_webmercator = st_multi(ST_MAKEVALID(st_transform(the_geom, 3857)));
CREATE INDEX gadm1_tgeomw_idx ON gadm1 USING GIST(the_geom_webmercator);

ALTER TABLE gadm2 ADD COLUMN the_geom_webmercator geometry(MultiPolygon, 3857);
UPDATE gadm2 SET the_geom_webmercator = st_multi(ST_MAKEVALID(st_transform(the_geom, 3857)));
CREATE INDEX gadm2_tgeomw_idx ON gadm2 USING GIST(the_geom_webmercator);

ALTER TABLE gadm3 ADD COLUMN the_geom_webmercator geometry(MultiPolygon, 3857);
UPDATE gadm0 SET the_geom_webmercator = st_multi(ST_MAKEVALID(st_transform(the_geom, 3857)));
CREATE INDEX gadm3_tgeomw_idx ON gadm3 USING GIST(the_geom_webmercator);

ALTER TABLE gadm4 ADD COLUMN the_geom_webmercator geometry(MultiPolygon, 3857);
UPDATE gadm0 SET the_geom_webmercator = st_multi(ST_MAKEVALID(st_transform(the_geom, 3857)));
CREATE INDEX gadm4_tgeomw_idx ON gadm4 USING GIST(the_geom_webmercator);

ALTER TABLE gadm5 ADD COLUMN the_geom_webmercator geometry(MultiPolygon, 3857);
UPDATE gadm0 SET the_geom_webmercator = st_multi(ST_MAKEVALID(st_transform(the_geom, 3857)));
CREATE INDEX gadm5_tgeomw_idx ON gadm5 USING GIST(the_geom_webmercator);



ALTER TABLE gadm0 ADD column located_at text;
ALTER TABLE gadm1 ADD column located_at text;
ALTER TABLE gadm2 ADD column located_at text;
ALTER TABLE gadm3 ADD column located_at text;
ALTER TABLE gadm4 ADD column located_at text;
ALTER TABLE gadm5 ADD column located_at text;

UPDATE gadm0 SET located_at = 'World';
UPDATE gadm1 SET located_at = name_0;
UPDATE gadm2 SET located_at = concat_ws(', ', name_1, name_0);
UPDATE gadm3 SET located_at = concat_ws(', ', name_2, name_1, name_0);
UPDATE gadm4 SET located_at = concat_ws(', ', name_3, name_2, name_1, name_0);
UPDATE gadm5 SET located_at = concat_ws(', ', name_4, name_3, name_2, name_1, name_0);

CREATE INDEX gadm0_located_idx ON gadm0 USING BTREE(located_at);
CREATE INDEX gadm1_located_idx ON gadm1 USING BTREE(located_at);
CREATE INDEX gadm2_located_idx ON gadm2 USING BTREE(located_at);
CREATE INDEX gadm3_located_idx ON gadm3 USING BTREE(located_at);
CREATE INDEX gadm4_located_idx ON gadm4 USING BTREE(located_at);
CREATE INDEX gadm5_located_idx ON gadm5 USING BTREE(located_at);


--view
DROP MATERIALIZED VIEW IF EXISTS gadm;
CREATE MATERIALIZED VIEW gadm AS
    SELECT
        name_0 as name,
        name_0 as name_0,
        null as name_1,
        null as name_2,
        null as name_3,
        null as name_4,
        null as name_5,
        'gadm0' as layer,
        engtype_0 as type,
        uid,
        located_at,
        the_geom_simp AS the_geom,
        the_geom_webmercator
    FROM
        gadm0

    UNION

    SELECT
        name_1 as name,
        name_0,
        name_1,
        null as name_2,
        null as name_3,
        null as name_4,
        null as name_5,
        'gadm1' as layer,
        engtype_1 as type,
        uid,
        located_at,
        the_geom_simp AS the_geom,
        the_geom_webmercator
    FROM
        gadm1

    UNION

    SELECT
        name_2 as name,
        name_0,
        name_1,
        name_2,
        null as name_3,
        null as name_4,
        null as name_5,
        'gadm2' as layer,
        engtype_2 as type,
        uid,
        located_at,
        the_geom_simp AS the_geom,
        the_geom_webmercator
    FROM
        gadm2

    UNION

    SELECT
        name_3 as name,
        name_0,
        name_1,
        name_2,
        name_3,
        null as name_4,
        null as name_5,
        'gadm3' as layer,
        engtype_3 as type,
        uid,
        located_at,
        the_geom_simp AS the_geom,
        the_geom_webmercator
    FROM
        gadm3

    UNION

    SELECT
        name_4 as name,
        name_0,
        name_1,
        name_2,
        name_3,
        name_4,
        null as name_5,
        'gadm4' as layer,
        engtype_4 as type,
        uid,
        located_at,
        the_geom_simp AS the_geom,
        the_geom_webmercator
    FROM
        gadm4

    UNION

    SELECT
        name_5 as name,
        name_0,
        name_1,
        name_2,
        name_3,
        name_4,
        name_5,
        'gadm5' as layer,
        engtype_5 as type,
        uid,
        located_at,
        the_geom_simp AS the_geom,
        the_geom_webmercator
    FROM
        gadm5;
CREATE INDEX gadm_name_idx ON gadm USING BTREE(name);
CREATE INDEX gadm_name0_idx ON gadm USING BTREE(name_0);
CREATE INDEX gadm_name1_idx ON gadm USING BTREE(name_1);
CREATE INDEX gadm_name2_idx ON gadm USING BTREE(name_2);
CREATE INDEX gadm_name3_idx ON gadm USING BTREE(name_3);
CREATE INDEX gadm_name4_idx ON gadm USING BTREE(name_4);
CREATE INDEX gadm_name5_idx ON gadm USING BTREE(name_5);
CREATE INDEX gadm_layer_idx ON gadm USING BTREE(layer);
CREATE INDEX gadm_type_idx ON gadm USING BTREE(type);
CREATE INDEX gadm_uid_idx ON gadm USING BTREE(uid);
CREATE INDEX gadm_locatedat_idx ON gadm USING BTREE(located_at);
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name));
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name_0));
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name_1));
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name_2));
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name_3));
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name_4));
CREATE INDEX ON gadm USING GIST (to_tsvector('mydict', name_5));
CREATE INDEX gadm_geom_idx ON gadm USING GIST(the_geom);
CREATE INDEX gadm_geomw_idx ON gadm USING GIST(the_geom_webmercator);

--alt names
DROP TABLE IF EXISTS gadm_alt_names CASCADE;
CREATE TABLE gadm_alt_names (
    altname_id uuid DEFAULT uuid_generate_v4(),
	uid uuid,
	language text DEFAULT 'en',
	source text DEFAULT 'gadm',
    alt_name text
);

--gadm1
INSERT INTO gadm_alt_names
    (uid, alt_name)
    (
        SELECT uid, unnest(string_to_array(varname_1, '|')) as name from gadm1 where varname_1 is not null
    );

--gadm2
INSERT INTO gadm_alt_names
    (uid, alt_name)
    (
        SELECT uid, unnest(string_to_array(varname_2, '|')) as name from gadm2 where varname_2 is not null
    );

--gadm3
INSERT INTO gadm_alt_names
    (uid, alt_name)
    (
        SELECT uid, unnest(string_to_array(varname_3, '|')) as name from gadm3 where varname_3 is not null
    );

--gadm4
INSERT INTO gadm_alt_names
    (uid, alt_name)
    (
        SELECT uid, unnest(string_to_array(varname_4, '|')) as name from gadm4 where varname_4 is not null
    );



CREATE INDEX gadm_alt_names_uuid_idx ON gadm_alt_names USING BTREE(uid);
CREATE INDEX gadm_alt_names_lang_idx ON gadm_alt_names USING BTREE(language);
CREATE INDEX gadm_alt_names_src_idx ON gadm_alt_names USING BTREE(source);
CREATE INDEX gadm_alt_names_altnam_idx ON gadm_alt_names USING GIST (to_tsvector('mydict', alt_name));




--gadm_types
DROP TABLE IF EXISTS gadm_types CASCADE;
CREATE TABLE gadm_types
(
    table_id serial,
    type text
);

INSERT INTO gadm_types
    (type)
    (
        SELECT distinct engtype_1 from gadm1
    );

INSERT INTO gadm_types
    (type)
    (
        SELECT distinct engtype_2 from gadm2
    );

INSERT INTO gadm_types
    (type)
    (
        SELECT distinct engtype_3 from gadm3
    );

INSERT INTO gadm_types
    (type)
    (
        SELECT distinct engtype_4 from gadm4
    );
	
INSERT INTO gadm_types
    (type)
    (
        SELECT distinct engtype_5 from gadm5
    );

CREATE INDEX gadm_types_idx ON gadm_types USING GIST (to_tsvector('mydict', type));



-- wikidata
DROP TABLE IF EXISTS gadm_wikidata CASCADE;
CREATE TABLE gadm_wikidata (
    table_id uuid DEFAULT uuid_generate_v4(),
	uid uuid,
	language text DEFAULT 'en',
	wikidata_id text,
    name text
);

CREATE INDEX gadm_wikidata_uid_idx ON gadm_wikidata USING BTREE (uid);
CREATE INDEX gadm_wikidata_lang_idx ON gadm_wikidata USING BTREE (language);
CREATE INDEX gadm_wikidata_wid_idx ON gadm_wikidata USING BTREE (wikidata_id);
CREATE INDEX gadm_wikidata_names_idx ON gadm_wikidata USING GIST (to_tsvector('mydict', name));


\copy (select uid, iso3, name_0 from gadm0) to 'gadm0.csv' CSV HEADER;

