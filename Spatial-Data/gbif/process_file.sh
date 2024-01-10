#!/bin/bash
#

while true
do
    # Load the segments to the occurrence table, then import to the final, and simplified, gbif table
    #for file in gbifdwca*; do
    for file in gbifdwc*; do
        echo $file
        #Replace backslashes in some text fields
        sed -i 's.\\./.g' $file
        psql -c "\copy gbif_occ FROM '$file';"
        rm $file
        psql -c "INSERT INTO gbif (gbifID, eventDate, basisOfRecord, recordedBy, occurrenceID, locationID, continent, waterBody, islandGroup, island, countryCode, stateProvince, county, municipality, locality, verbatimLocality, locationAccordingTo, locationRemarks, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, coordinatePrecision, pointRadiusSpatialFit, georeferencedBy, georeferencedDate, georeferenceProtocol, georeferenceSources, georeferenceVerificationStatus, georeferenceRemarks, taxonConceptID, scientificName, higherClassification, kingdom, phylum, class, _order, family, genus, subgenus, specificEpithet, infraspecificEpithet, taxonRank, vernacularName, nomenclaturalCode, taxonomicStatus, nomenclaturalStatus, taxonRemarks, datasetKey, issue, hasGeospatialIssues, taxonKey, acceptedTaxonKey, species, genericName, acceptedScientificName, the_geom, the_geom_webmercator) (SELECT gbifID, eventDate, basisOfRecord, recordedBy, occurrenceID, locationID, continent, waterBody, islandGroup, island, countryCode, stateProvince, county, municipality, locality, verbatimLocality, locationAccordingTo, locationRemarks, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, coordinatePrecision, pointRadiusSpatialFit, georeferencedBy, georeferencedDate, georeferenceProtocol, georeferenceSources, georeferenceVerificationStatus, georeferenceRemarks, taxonConceptID, scientificName, higherClassification, kingdom, phylum, class, _order, family, genus, subgenus, specificEpithet, infraspecificEpithet, taxonRank, vernacularName, nomenclaturalCode, taxonomicStatus, nomenclaturalStatus, taxonRemarks, datasetKey, issue, hasGeospatialIssues, taxonKey, acceptedTaxonKey, species, genericName, acceptedScientificName, ST_SETSRID(ST_POINT(decimalLongitude, decimalLatitude), 4326) as the_geom, ST_TRANSFORM(ST_SETSRID(ST_POINT(decimalLongitude, decimalLatitude), 4326), 3857) as the_geom_webmercator FROM gbif_occ WHERE locality != '' AND species != '' AND decimalLongitude != 0 AND decimalLatitude != 0 AND decimalLongitude IS NOT NULL AND decimalLatitude IS NOT NULL AND decimalLongitude != 180 AND decimalLatitude != 90 AND decimalLongitude != -180 AND decimalLatitude != -90);"
        psql -c "TRUNCATE gbif_occ;"
    done

sleep 30

done

