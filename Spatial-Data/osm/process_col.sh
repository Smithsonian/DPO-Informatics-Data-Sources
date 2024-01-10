#!/bin/bash
#

echo "Working on column $1..."
psql -c "CREATE INDEX osmplanet_p_$1_idx ON planet_osm_polygon USING BTREE(\"$1\") WHERE \"$1\" IS NOT NULL;"
psql -c "with data as ( 
                                        select 
                                            osm_id as osm_id, 
                                            name,
                                            \"$1\",
                                            st_makevalid(st_multi(way)) as way
                                        from 
                                            planet_osm_polygon 
                                        where 
                                            \"$1\" IS NOT NULL AND
                                            name IS NOT NULL
                                    )
                                INSERT INTO osm_polygons
                                    (source_id, name, type, attributes, centroid, the_geom, the_geom_webmercator, gadm2, country, data_source) 
                                    select 
                                        d.osm_id::text, 
                                        d.name, 
                                        coalesce(replace(\"$1\", 'yes', NULL), \"$1\"),
                                        tags::hstore,
                                        st_centroid(way),
                                        way as the_geom,
                                        st_transform(way, 3857) as the_geom_webmercator,
                                        g.name_2 || ', ' || g.name_1 || ', ' || g.name_0 as loc,
                                        g.name_0 as name_0,
                                        '$2'
                                    from 
                                        data d LEFT JOIN 
                                            planet_osm_ways r ON 
                                            (d.osm_id = r.id)
                                        LEFT JOIN 
                                            gadm2 g ON 
                                            ST_INTERSECTS(way, g.the_geom_simp);"

#points
#psql -c "CREATE INDEX osmplanet_po_$1_idx ON planet_osm_polygon USING BTREE(\"$1\") WHERE \"$1\" IS NOT NULL;"
#psql -c "with data as (
#                                        select
#                                            osm_id as osm_id,
#                                            name,
#                                            \"$1\",
#                                            st_makevalid(way) as way
#                                        from
#                                            planet_osm_polygon
#                                        where
#                                            \"$1\" IS NOT NULL AND
#                                            name IS NOT NULL
#                                    )
#                                INSERT INTO osm_points
#                                    (source_id, name, type, attributes, the_geom, the_geom_webmercator, gadm2, country, data_source)
#                                    select
#                                        d.osm_id::text,
#                                        d.name,
#                                        coalesce(replace(\"$1\", 'yes', NULL), \"$1\"),
#                                        tags::hstore,
#                                        way as the_geom,
#                                        st_transform(way, 3857) as the_geom_webmercator,
#                                        g.name_2 || ', ' || g.name_1 || ', ' || g.name_0 as loc,
#                                        g.name_0 as name_0,
#                                        '$2'
#                                    from
#                                        data d LEFT JOIN
#                                            planet_osm_ways r ON
#                                            (d.osm_id = r.id)
#                                        LEFT JOIN
#                                            gadm2 g ON
#                                            ST_INTERSECTS(way, g.the_geom_simp);"

psql -c "DROP INDEX osmplanet_p_$1_idx;"
#psql -c "DROP INDEX osmplanet_po_$1_idx;"

