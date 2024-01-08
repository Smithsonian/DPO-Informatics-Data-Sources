#!/usr/bin/env python3

# Using SPARQLWrapper to query data from wikidata.

from SPARQLWrapper import SPARQLWrapper
from SPARQLWrapper import JSON
import pandas as pd

sparql = SPARQLWrapper('http://query.wikidata.org/sparql')

# Replace query in block as desired
sparql.setQuery('''
               SELECT ?country ?countryLabel ?label (lang(?label) as ?lang_code)
                WHERE {{
                  VALUES ?country {{ wd:{} }} # Select instance of specific country United States of America
                  ?country rdfs:label ?label. # Display country label
                  
                  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en". }}
                }}
                '''.format(country_id))

sparql.setReturnFormat(JSON)
results = sparql.query().convert()

# # Print results as JSON
# for result in results["results"]["bindings"]:
#     print(results)

# Print results as dataframe to string
results_df = pd.json_normalize(results['results']['bindings'])
print(results_df.to_string())
