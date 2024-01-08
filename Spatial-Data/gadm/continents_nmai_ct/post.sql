--Make sure all the geoms are multipolygons and that they are valid
UPDATE gadm_continents_nmai_ct SET the_geom = ST_MULTI(ST_SETSRID(the_geom, 4326));
UPDATE gadm_continents_nmai_ct SET the_geom = ST_MAKEVALID(the_geom) WHERE ST_ISVALID(the_geom) = 'F';

CREATE INDEX gadm_continents_nmai_ct_name0_idx ON gadm_continents_nmai_ct USING gin (name gin_trgm_ops);
CREATE INDEX gadm_continents_nmai_ct_the_geom_idx ON gadm_continents_nmai_ct USING gist (the_geom);

--Simplified geoms
ALTER TABLE gadm_continents_nmai_ct ADD COLUMN the_geom_simp geometry;
UPDATE gadm_continents_nmai_ct SET the_geom_simp = ST_SIMPLIFY(the_geom, 0.01);
CREATE INDEX gadm_continents_nmai_ct_the_geom_simp_idx ON gadm_continents_nmai_ct USING GIST(the_geom_simp);

ALTER TABLE gadm_continents_nmai_ct ADD COLUMN the_geom_webmercator geometry;
UPDATE gadm_continents_nmai_ct SET the_geom_webmercator = st_transform(the_geom, 3857);
CREATE INDEX gadm_continents_nmai_ct_tgeomw_idx ON gadm_continents_nmai_ct USING GIST(the_geom_webmercator);
