#!/usr/bin/env python3
#
# Import AW taxonomy

import psycopg2

import simplejson as json
import psycopg2
import psycopg2.extras
from psycopg2.extensions import AsIs
import pandas as pd
import sys
import csv
import io

import settings


try:
    conn = psycopg2.connect(host=settings.pg_host,
                            database=settings.pg_db,
                            user=settings.pg_user)
except psycopg2.Error as e:
    print(e)
    sys.exit(1)

conn.autocommit = True
conn.set_client_encoding('UTF8')

cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

thes_id = 'aw_amphibians'


cur.execute("delete from th_thesaurus WHERE thesaurus_id = %s", (thes_id,))
cur.execute("INSERT INTO th_thesaurus (thesaurus_id, thesaurus_name, thesaurus_type) VALUES (%s, "
            "'AmphibiaWeb (2022)', 'bio_taxonomy')", (thes_id,))


cur.execute("delete from th_ranks WHERE thesaurus_id = %s", (thes_id, ))

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES (%s, 'Order') "
                      "RETURNING rank_id", (thes_id, ))
l0_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES (%s, 'Family') "
                      "RETURNING rank_id", (thes_id, ))
l1_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES (%s, 'Subfamily') "
                      "RETURNING rank_id", (thes_id, ))
l2_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES (%s, 'Genus') "
                      "RETURNING rank_id", (thes_id, ))
l3_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES (%s, 'Subgenus') "
                      "RETURNING rank_id", (thes_id, ))
l4_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES (%s, 'Species') "
                      "RETURNING rank_id", (thes_id, ))
l5_rank = cur.fetchone()['rank_id']


filename = 'amphib_names.txt'


query_elements = "INSERT INTO th_elements (element_name, element_parent, rank_id, element_source_id) VALUES " \
                 "  (%(element_name)s, %(element_parent)s, %(rank_id)s, %(element_source_id)s)" \
                 "ON CONFLICT (element_name, rank_id, element_source_id) DO UPDATE SET element_name = %(element_name)s RETURNING element_id"

query_name = "INSERT INTO th_elements_alt (element_name_alt, element_id, element_source_id, element_description_alt) VALUES " \
                 "  (%(element_name_alt)s, %(element_id)s, %(element_source_id)s, %(element_description_alt)s)" \
                 "ON CONFLICT (element_name_alt, element_id, element_source_id) DO UPDATE SET element_name_alt = %(element_name_alt)s RETURNING element_id_alt"


with open(filename, newline='', encoding='utf-8') as csvfile:
    datareader = csv.reader(csvfile, delimiter='\t')
    for row in datareader:
        #0
        cur.execute(query_elements, {'element_name': row[0] , 'element_parent': AsIs("NULL"), 'element_source_id': row[15], 'rank_id': l0_rank})
        parent_id = cur.fetchone()['element_id']
        print(row[0])
        #1
        cur.execute(query_elements, {'element_name': row[1], 'element_parent': parent_id, 'element_source_id': row[15], 'rank_id': l1_rank})
        parent_id = cur.fetchone()['element_id']
        print(row[1])
        # 2
        if row[2] != '':
            cur.execute(query_elements, {'element_name': row[2], 'element_parent': parent_id, 'element_source_id': row[15], 'rank_id': l2_rank})
            parent_id = cur.fetchone()['element_id']
            print(row[2])
        # 3
        cur.execute(query_elements, {'element_name': row[3], 'element_parent': parent_id, 'element_source_id': row[15], 'rank_id': l3_rank})
        parent_id = cur.fetchone()['element_id']
        print(row[3])
        # 4
        if row[4] != '':
            cur.execute(query_elements, {'element_name': row[4], 'element_parent': parent_id, 'element_source_id': row[15], 'rank_id': l4_rank})
            parent_id = cur.fetchone()['element_id']
            print(row[4])
        # species
        cur.execute(query_elements, {'element_name': row[5], 'element_parent': parent_id, 'element_source_id': row[15], 'rank_id': l5_rank})
        species_id = cur.fetchone()['element_id']
        print(row[5])
        # cm name
        if row[7] != '':
            for name in row[7].split(', '):
                cur.execute(query_name, {'element_name_alt': name, 'element_id': species_id, 'element_source_id': row[15], 'element_description_alt': 'Common Name'})
                parent_id = cur.fetchone()['element_id_alt']
            print(row[7])
        if row[9] != '':
            for name in row[9].split(', '):
                cur.execute(query_name, {'element_name_alt': name, 'element_id': species_id, 'element_source_id': row[15], 'element_description_alt': 'Synonym'})
                parent_id = cur.fetchone()['element_id_alt']
            print(row[9])
        if row[10] != '':
            for name in row[10].split(', '):
                cur.execute(query_name, {'element_name_alt': name, 'element_id': species_id, 'element_source_id': row[15], 'element_description_alt': 'ITIS Synonym'})
                parent_id = cur.fetchone()['element_id_alt']
            print(row[10])
        if row[16] != '':
            cur.execute("INSERT INTO th_elements_notes (element_id, element_note) VALUES (%(element_id)s, %(element_note)s)", {'element_id': species_id, 'element_note': row[16]})
            print(row[10])
        else:
            print("Row ended.")
            continue




cur.close()
conn.close()
