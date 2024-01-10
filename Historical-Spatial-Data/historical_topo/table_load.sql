DROP TABLE IF EXISTS historical_topo CASCADE;

create table historical_topo (
    product_inventory_uuid text,
	series text,
	edition text,
	map_name text,
	primary_state text,
	gnis_cell_id text,
	westbc text,
	eastbc text,
	northbc text,
	southbc text,
	geom_wkt text,
	grid_size text,
	cell_type text,
	state_list text,
	county_list text,
	date_on_map text,
	print_year text,
	metadata_date text,
	map_scale text,
	page_width_inches text,
	page_height_inches text,
	product_filename text,
	product_format text,
	product_filesize text,
	db_uuid text,
	inv_uuid text,
	product_url text,
	thumbnail_url text,
	sciencebase_url text,
	metadata_url text
);

\copy historical_topo FROM 'historicaltopo.csv' CSV HEADER;

ALTER TABLE historical_topo ADD COLUMN the_geom geometry;
UPDATE historical_topo SET the_geom = ST_SETSRID(ST_GeomFromText(geom_wkt), 4326);

CREATE INDEX historical_topo_thegeom_idx ON historical_topo USING GIST(the_geom);
CREATE INDEX historical_topo_state_idx ON historical_topo USING btree(primary_state);
CREATE INDEX historical_topo_date_idx ON historical_topo USING btree(date_on_map);
CREATE INDEX historical_topo_statel_idx ON historical_topo USING gin(state_list gin_trgm_ops);
CREATE INDEX historical_topo_countyl_idx ON historical_topo USING gin(county_list gin_trgm_ops);

\copy (select 'wget', '-c', '-O', '"pdf/' || product_inventory_uuid || '.pdf"', '"' || product_url || '"' FROM historical_topo limit 5000) to 'download.sh' DELIMITER ' ';


select product_inventory_uuid, count(*)
  from historical_topo
 group by product_inventory_uuid
having count(*) > 1;
