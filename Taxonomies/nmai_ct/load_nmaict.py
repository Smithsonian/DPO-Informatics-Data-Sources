#!/usr/bin/env python3
#
# Import NMAI CT

import psycopg2

# import simplejson as json
import psycopg2
import psycopg2.extras
from psycopg2.extensions import AsIs
# import pandas as pd
import sys
import csv
import io

import settings


try:
    conn = psycopg2.connect(host=settings.pg_host,
                            database=settings.pg_db,
                            user=settings.pg_user,
                            password=settings.pg_password)
except psycopg2.Error as e:
    print(e)
    sys.exit(1)

conn.autocommit = True
conn.set_client_encoding('UTF8')

cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

thes_id = 'nmai_ct'


cur.execute("delete from th_thesaurus WHERE thesaurus_id = %s", (thes_id,))
cur.execute("INSERT INTO th_thesaurus (thesaurus_id, thesaurus_name, thesaurus_type) VALUES (%s, "
            "'NMAI Cultural Thesaurus', 'culture')", (thes_id,))


cur.execute("delete from th_ranks WHERE thesaurus_id = %s", (thes_id, ))


cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'Root') RETURNING rank_id")
root_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_elements (element_name, element_parent, rank_id) VALUES ('World', NULL, %(rank_id)s) "
            "RETURNING element_id", {'rank_id': root_rank})
root_id = cur.fetchone()['element_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L1 - Continent') "
                      "RETURNING rank_id")
l1_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L2 - Culture Area') "
                      "RETURNING rank_id")
l2_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L3 - Sub-Culture Area') "
                      "RETURNING rank_id")
l3_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L4 - Culture') "
                      "RETURNING rank_id")
l4_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L5 - Sub-Culture') "
                      "RETURNING rank_id")
l5_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L6 - Community') "
                      "RETURNING rank_id")
l6_rank = cur.fetchone()['rank_id']

cur.execute("INSERT INTO th_ranks (thesaurus_id, rank_name) VALUES ('nmai_ct', 'L7 - Sub-Community?') "
                      "RETURNING rank_id")
l7_rank = cur.fetchone()['rank_id']


filename = 'nmai_ct.csv'


query_elements = "INSERT INTO th_elements (element_name, rank_id, element_source_id) VALUES " \
                 "  (%(element_name)s, %(rank_id)s, '') " \
                 "ON CONFLICT (element_name, rank_id, element_source_id) DO UPDATE SET element_name = %(element_name)s RETURNING " \
                 "element_id"

query_elements_sourceid = "INSERT INTO th_elements (element_name, rank_id, element_source_id) VALUES " \
                 "  (%(element_name)s, %(rank_id)s, %(element_source_id)s) " \
                 "ON CONFLICT (element_name, rank_id, element_source_id) DO UPDATE SET element_name = %(element_name)s RETURNING " \
                 "element_id"

insert_parent = "INSERT INTO th_elements_relationships (element_id, element_relationship, element_relationship_type) " \
                "VALUES " \
                 "  (%(element_id)s, %(element_parent)s, 'parent') " \
                 "ON CONFLICT (element_id, element_relationship, element_relationship_type) DO UPDATE SET element_relationship = %(element_parent)s"

add_names = "INSERT INTO th_elements_alt (element_id, element_name_alt, element_source_id) VALUES " \
            "(%(element_id)s, " \
            "trim(unnest(string_to_array(%(element_name_alt)s, '|'))), '') " \
            "ON CONFLICT (element_id, element_name_alt, element_source_id) DO UPDATE SET element_name_alt = %(element_name_alt)s RETURNING " \
                 "element_id"

add_notes = "INSERT INTO th_elements_notes (element_id, element_note) VALUES " \
            "(%(element_id)s, %(element_note)s) " \
            "ON CONFLICT (element_id, element_note) DO UPDATE SET element_note = %(element_note)s RETURNING element_id"


def insert_row(parent_id, element_name, rank_id, check_cell, row):
    if check_cell == "":
        # cur.execute(query_elements_sourceid, {'element_name': element_name, 'element_parent': parent_id, 'rank_id':
        #    rank_id, 'element_source_id': row[0]})
        cur.execute(query_elements, {'element_name': element_name, 'rank_id': rank_id})
        element_id = cur.fetchone()['element_id']
        print("element_id: {}".format(element_id))
        print(cur.query)
        # Insert parent
        cur.execute(insert_parent, {'element_id': element_id, 'element_parent': parent_id})
        # Insert names, langs
        if row[1] != "":
            all_names = row[1].split('|')
            for name in all_names:
                cur.execute(add_names, {'element_id': element_id, 'element_name_alt': name.strip()})
                print("all_names: {}".format(all_names))
                print(cur.query)
        if row[2] != "":
            cur.execute(add_notes, {'element_id': element_id, 'element_note': row[2]})
            print("element_note: {}".format(row[2]))
            print(cur.query)
        #print("Row ended.")
        # continue
    else:
        cur.execute(query_elements, {'element_name': element_name, 'rank_id': rank_id})
        element_id = cur.fetchone()['element_id']
        print("element_id (no id): {}".format(element_id))
        print(cur.query)
        # Insert parent
        cur.execute(insert_parent, {'element_id': element_id, 'element_parent': parent_id})
        print("element_parent (no id): {}".format(parent_id))
        print(cur.query)
    return element_id, check_cell



with open(filename, newline='', encoding='utf-8') as csvfile:
    datareader = csv.reader(csvfile)
    for row in datareader:
        # 1
        parent_id = root_id
        element_name = row[4]
        rank_id = l1_rank
        check_cell = row[5]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, check_cell, row)
        if check_cell == "":
            print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
            continue
        # 2
        element_name = row[5]
        rank_id = l2_rank
        check_cell = row[6]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, check_cell, row)
        if check_cell == "":
            print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
            continue
        # 3
        element_name = row[6]
        rank_id = l3_rank
        check_cell = row[7]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, check_cell, row)
        if check_cell == "":
            print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
            continue
        # 4
        element_name = row[7]
        rank_id = l4_rank
        check_cell = row[8]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, check_cell, row)
        if check_cell == "":
            print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
            continue
        # 5
        element_name = row[8]
        rank_id = l5_rank
        check_cell = row[9]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, check_cell, row)
        if check_cell == "":
            print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
            continue
        # 6
        element_name = row[9]
        rank_id = l6_rank
        check_cell = row[10]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, check_cell, row)
        if check_cell == "":
            print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
            continue
        # 7
        element_name = row[10]
        rank_id = l7_rank
        # check_cell = row[11]
        parent_id, check_cell = insert_row(parent_id, element_name, rank_id, "", row)
        print("{}: stopping row at {} - {}\n".format(row, element_name, parent_id))
        continue



cur.close()
conn.close()
