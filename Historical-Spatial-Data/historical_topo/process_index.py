#!/usr/bin/env python3

import sys
import json
import subprocess
import os
import pandas as pd
import xml.etree.ElementTree as ET
import requests
import shutil
import time


file = "historicaltopo.csv"

datafile = pd.read_csv(file)


os.makedirs("jpgs", exist_ok=True)
os.makedirs("tifs", exist_ok=True)
os.makedirs("xml", exist_ok=True)


nrows = datafile.shape[0]
i=1


for _, row in datafile.iterrows():
    dl_id = row['product_inventory_uuid']
    xml_file = row['metadata_url']
    print("Downloading XML {} of {}...\n".format(i, nrows))
    i += 1
    
    # saving the xml file
    xmlfile = '{}.xml'.format(dl_id)
    if os.path.isfile("xml/{}".format(xmlfile)):
        tree = ET.parse("xml/{}".format(xmlfile))
    else:
        # creating HTTP response object from given url
        try:
            resp = requests.get(xml_file)
            with open(xmlfile, 'wb') as f:
                f.write(resp.content)
        except: 
            time.sleep(5)
            try:
                resp = requests.get(xml_file)
                with open(xmlfile, 'wb') as f:
                    f.write(resp.content)
            except: 
                continue
        
        try:
            tree = ET.parse(xmlfile)
        except: 
            continue
        
    root = tree.getroot()

    # iterate news items
    for item in root.findall('./distinfo/stdorder/digform/digtopt/onlinopt/computer/networka/networkr'):
        if item.text[-4:] == ".tif":
            
            tif_file = "{}.tif".format(dl_id)
            jpg_file = "{}.jpg".format(dl_id)
            if os.path.isfile("tifs/{}".format(tif_file)) and os.path.isfile("jpgs/{}".format(jpg_file)):
                print("Skipping file {}...".format(item.text))
                if os.path.isfile("{}".format(xmlfile)):
                    shutil.move(xmlfile, "xml/{}".format(xmlfile))
                continue
            print(item.text)
            p = subprocess.Popen(['wget', '-q', '-O', tif_file, item.text], stdout=subprocess.PIPE,
                                             stderr=subprocess.PIPE)
            (out, err) = p.communicate()
            if out != b'':
                print("wget returned error: {} | {}".format(err, out))
                sys.exit(1)
            # Export to jpg
            p = subprocess.Popen(['convert', "{}[0]".format(tif_file), jpg_file], stdout=subprocess.PIPE,
                                             stderr=subprocess.PIPE)
            (out, err) = p.communicate()
            if out != b'':
                print("wget returned error: {} | {}".format(err, out))
                sys.exit(1)
            try:
                shutil.move(tif_file, "tifs/{}".format(tif_file))
                shutil.move(jpg_file, "jpgs/{}".format(jpg_file))
                shutil.move(xmlfile, "xml/{}".format(xmlfile))
            except: 
                continue

