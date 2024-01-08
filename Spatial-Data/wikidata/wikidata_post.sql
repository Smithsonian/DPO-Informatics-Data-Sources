
--View
DROP MATERIALIZED VIEW wikidata;
CREATE MATERIALIZED VIEW wikidata AS
    WITH data AS (
        SELECT
            r.uid, r.source_id, r.latitude, r.longitude, n.name, r.type, r.gadm1, 'wikidata' AS data_source, n.language, r.the_geom
        FROM 
            wikidata_records r, wikidata_names n 
        WHERE 
            r.source_id = n.source_id
        )
    SELECT uid, source_id, latitude, longitude, name, type, gadm1, data_source, language, the_geom FROM data WHERE name IS NOT NULL GROUP BY uid, source_id, latitude, longitude, name, type, gadm1, data_source, language, the_geom;
CREATE INDEX wikidata_v_uid_idx ON wikidata USING BTREE(uid);
CREATE INDEX wikidata_v_name_idx ON wikidata USING gin (name gin_trgm_ops);
CREATE INDEX wikidata_v_gadm1_idx ON wikidata USING gin (gadm1 gin_trgm_ops);
CREATE INDEX wikidata_v_geom_idx ON wikidata USING GIST(the_geom);

UPDATE data_sources SET no_features = w.no_feats FROM (select count(*) as no_feats from wikidata) w WHERE datasource_id = 'wikidata';
UPDATE data_sources SET is_online = 'T', source_date = CURRENT_DATE WHERE datasource_id = 'wikidata';
