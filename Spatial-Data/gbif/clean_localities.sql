DROP TABLE IF EXISTS gbif_localities;
CREATE TABLE gbif_localities(
    gbifID text,
    no_records int,
    locationID text,
    continent text,
    waterBody text,
    islandGroup text,
    island text,
    countryCode text,
    stateProvince text,
    county text,
    municipality text,
    locality text,
    decimalLatitude float,
    decimalLongitude float,
    coordinateUncertaintyInMeters text,
    coordinatePrecision text,
    pointRadiusSpatialFit text,
    kingdom text,
    phylum text,
    class text,
    hasGeospatialIssues text,
    the_geom geometry(geometry, 4326),
    the_geom_webmercator geometry(geometry, 3857)
);


INSERT INTO gbif_localities (
    SELECT
          max(gbifID) as gbifID,
          count(*) as no_records,
          locationID,
          continent,
          waterBody,
          islandGroup,
          island,
          countryCode,
          stateProvince,
          county,
          municipality,
          locality,
          decimalLatitude,
          decimalLongitude,
          coordinateUncertaintyInMeters,
          coordinatePrecision,
          pointRadiusSpatialFit,
          kingdom,
          phylum,
          class,
          hasGeospatialIssues,
          the_geom,
          the_geom_webmercator
      FROM
        gbif_00
      GROUP BY
          locationID,
          continent,
          waterBody,
          islandGroup,
          island,
          countryCode,
          stateProvince,
          county,
          municipality,
          locality,
          decimalLatitude,
          decimalLongitude,
          coordinateUncertaintyInMeters,
          coordinatePrecision,
          pointRadiusSpatialFit,
          kingdom,
          phylum,
          class,
          hasGeospatialIssues,
          the_geom,
          the_geom_webmercator
    );



CREATE INDEX gbif_19_taxokin_idx ON gbif_19 USING btree(kingdom);
CREATE INDEX gbif_19_taxophy_idx ON gbif_19 USING btree(phylum);
CREATE INDEX gbif_19_taxocla_idx ON gbif_19 USING btree(class);
CREATE INDEX gbif_19_taxoord_idx ON gbif_19 USING btree(_order);
CREATE INDEX gbif_19_taxofam_idx ON gbif_19 USING btree(family);
CREATE INDEX gbif_19_basisrec_idx ON gbif_19 USING btree(basisOfRecord);
