
alter table paleodb add column the_geom geometry;
update paleodb set the_geom = st_setsrid(st_point(lng::numeric, lat::numeric), 4326);
alter table paleodb add column the_geom_webmercator geometry;
update paleodb set the_geom_webmercator = st_transform(the_geom, 3857) where st_isvalid(st_transform(the_geom, 3857));
CREATE INDEX paleodb_the_geom_idx ON paleodb USING gist (the_geom);
CREATE INDEX paleodb_the_geomw_idx ON paleodb USING gist (the_geom_webmercator);


alter table paleodb add column uid uuid DEFAULT uuid_generate_v4();
CREATE INDEX paleodb_uid_idx ON paleodb USING btree (uid);


CREATE INDEX paleodb_state_trgm_idx ON paleodb USING gin (state gin_trgm_ops);
CREATE INDEX paleodb_county_trgm_idx ON paleodb USING gin (county gin_trgm_ops);
CREATE INDEX paleodb_identified_name_trgm_idx ON paleodb USING gin (identified_name gin_trgm_ops);
CREATE INDEX paleodb_identified_rank_trgm_idx ON paleodb USING gin (identified_rank gin_trgm_ops);
CREATE INDEX paleodb_accepted_name_trgm_idx ON paleodb USING gin (accepted_name gin_trgm_ops);
CREATE INDEX paleodb_accepted_rank_trgm_idx ON paleodb USING gin (accepted_rank gin_trgm_ops);
CREATE INDEX paleodb_phylum_trgm_idx ON paleodb USING gin (phylum gin_trgm_ops);

CREATE INDEX paleodb_phylum_trgm_idx ON paleodb USING gin (phylum gin_trgm_ops);
CREATE INDEX paleodb_class_trgm_idx ON paleodb USING gin (class gin_trgm_ops);
CREATE INDEX paleodb_order_trgm_idx ON paleodb USING gin (_order gin_trgm_ops);
CREATE INDEX paleodb_family_trgm_idx ON paleodb USING gin (family gin_trgm_ops);
CREATE INDEX paleodb_genus_trgm_idx ON paleodb USING gin (genus gin_trgm_ops);
