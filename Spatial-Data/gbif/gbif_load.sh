#!/bin/bash
#
# Load the records with locality and coordinates from a full GBIF dump to a Postsi_thesaurus database.
#
# First, download the latest full DarwinCore data dump from:
#    https://gbif.org
#
# Then, unzip the files that the script will use
#    unzip 000##########.zip -x occurrence.txt meta.xml verbatim.txt citations.txt multimedia.txt rights.txt
#

#Today's date
script_date=$(date +'%Y-%m-%d')

unzip 000.zip -x occurrence.txt meta.xml verbatim.txt citations.txt multimedia.txt rights.txt

psql -c "UPDATE data_sources SET is_online = 'f' WHERE datasource_id = 'gbif';"

#Setup tables
psql < gbif_tables.sql


#unzip file and break into pieces via pipes
unzip -p 000.zip occurrence.txt | tail -n +2 | split -l 500000 - gbifdwc


mkdir done

# Load the segments to the occurrence table, then import to the final, and simplified, gbif table
#for file in gbifdwca*; do
for file in gbifdwc*; do
    echo $file
    #Replace backslashes in some text fields
    sed -i 's.\\./.g' $file
    psql -c "\copy gbif_occ FROM '$file';"
    mv $file done/
    psql -c "INSERT INTO gbif (gbifID, eventDate, basisOfRecord, recordedBy, occurrenceID, locationID, continent, waterBody, islandGroup, island, countryCode, stateProvince, county, municipality, locality, verbatimLocality, locationAccordingTo, locationRemarks, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, coordinatePrecision, pointRadiusSpatialFit, georeferencedBy, georeferencedDate, georeferenceProtocol, georeferenceSources, georeferenceVerificationStatus, georeferenceRemarks, taxonConceptID, scientificName, higherClassification, kingdom, phylum, class, _order, family, genus, subgenus, specificEpithet, infraspecificEpithet, taxonRank, vernacularName, nomenclaturalCode, taxonomicStatus, nomenclaturalStatus, taxonRemarks, datasetKey, issue, hasGeospatialIssues, taxonKey, acceptedTaxonKey, species, genericName, acceptedScientificName, the_geom, the_geom_webmercator) (SELECT gbifID, eventDate, basisOfRecord, recordedBy, occurrenceID, locationID, continent, waterBody, islandGroup, island, countryCode, stateProvince, county, municipality, locality, verbatimLocality, locationAccordingTo, locationRemarks, decimalLatitude, decimalLongitude, coordinateUncertaintyInMeters, coordinatePrecision, pointRadiusSpatialFit, georeferencedBy, georeferencedDate, georeferenceProtocol, georeferenceSources, georeferenceVerificationStatus, georeferenceRemarks, taxonConceptID, scientificName, higherClassification, kingdom, phylum, class, _order, family, genus, subgenus, specificEpithet, infraspecificEpithet, taxonRank, vernacularName, nomenclaturalCode, taxonomicStatus, nomenclaturalStatus, taxonRemarks, datasetKey, issue, hasGeospatialIssues, taxonKey, acceptedTaxonKey, species, genericName, acceptedScientificName, ST_SETSRID(ST_POINT(decimalLongitude, decimalLatitude), 4326) as the_geom, ST_TRANSFORM(ST_SETSRID(ST_POINT(decimalLongitude::numeric, decimalLatitude), 4326), 3857) as the_geom_webmercator FROM gbif_occ WHERE locality != '' AND species != '' AND decimalLongitude != 0 AND decimalLatitude != 0 AND decimalLongitude IS NOT NULL AND decimalLatitude IS NOT NULL AND decimalLongitude != 180 AND decimalLatitude != 90 AND decimalLongitude != -180 AND decimalLatitude != -90);"
    psql -c "TRUNCATE gbif_occ;"
done

#Delete temp table
psql -c "DROP TABLE IF EXISTS gbif_occ CASCADE;"
psql -c "DROP TABLE IF EXISTS gbif_occ2 CASCADE;"


#Extract dataset info
cp gbifdatasets.py dataset/
cd dataset/
python3 gbifdatasets.py
mv gbifdatasets.csv ../
cd ../
psql < gbifdatasets_table.sql
rm gbifdatasets.csv
rm -r dataset

#Create indices, other post-insert cleanup
psql < post_insert_indices2.sql
psql < post_insert_indices3.sql
psql < post_insert_indices4.sql
psql < post_insert_indices.sql


#Extract doi from DwC download using xpath
title_doi=`xpath -q -e '//dataset/title/text()' metadata.xml`

#rm metadata.xml

#Turn datasource online
psql -c "UPDATE data_sources SET is_online = 't', source_date = '$script_date', source_title = '$title_doi', no_features = w.no_feats FROM (select count(*) as no_feats from gbif) w WHERE datasource_id = 'gbif';"
