#!/bin/bash
#
# Split the files into 2 folders for parallel processing into gbif_occ and gbif_occ2
#

while true
do

    for file in gbifdwc*; do
        mv $file 2/
    done
    sleep 90

    for file in gbifdwc*; do
        mv $file 3/
    done
    sleep 90

done
