create table gns (
    rk text,
    ufi text,
    uni text,
    full_name text,
    nt text,
    lat_dd text,
    long_dd text,
    efctv_dt text,
    term_dt_f text,
    term_dt_n text,
    desig_cd text,
    fc text,
    cc_ft text,
    adm1 text,
    ft_link text,
    name_rank text,
    lang_cd text,
    transl_cd text,
    script_cd text,
    name_link text,
    cc_nm text,
    generic text,
    full_nm_nd text,
    sort_gen text,
    sort_name text,
    lat_dms text,
    long_dms text,
    mgrs text,
    mod_dt_ft text,
    mod_dt_nm text,
    dialect_cd text,
    display text,
    gis_notes text
);


\copy gns FROM 'Whole_World.txt';

ALTER TABLE gns ADD COLUMN the_geom geometry(POINT, 4326);
UPDATE gns SET the_geom = ST_SETSRID(ST_POINT(long_dd::numeric, lat_dd::numeric), 4326);
CREATE INDEX gns_thegeom_idx ON gns USING GIST(the_geom);

ALTER TABLE gns ADD COLUMN the_geom_webmercator geometry(POINT, 3857);
UPDATE gns SET the_geom_webmercator = ST_TRANSFORM(the_geom, 3857);
CREATE INDEX gns_thegeomw_idx ON gns USING GIST(the_geom_webmercator);

--For ILIKE queries
CREATE INDEX gns_name_trgm_idx ON gns USING gin (full_name gin_trgm_ops);
--CREATE INDEX gns_country_idx ON gns USING BTREE(cc1);

alter table gns add column uid uuid DEFAULT uuid_generate_v4();
CREATE INDEX gns_uid_idx ON gns USING BTREE(uid);


--Add webmercator
/*ALTER TABLE gns ADD COLUMN the_geom_webmercator geometry(POINT, 3857);
UPDATE gns SET the_geom_webmercator = ST_Transform(the_geom, 3857);
CREATE INDEX gns_thegeomw_idx ON gns USING GIST(the_geom_webmercator);*/

--Add gadm2 intersection
ALTER TABLE gns ADD COLUMN gadm2 text;

UPDATE gns geo SET gadm2 = g.name_2 || ', ' || g.name_1 || ', ' || g.name_0 FROM gadm2 g WHERE ST_INTERSECTS(geo.the_geom, g.the_geom);

CREATE INDEX gns_gin_gadm2_idx ON gns USING gin(gadm2 gin_trgm_ops);
