import requests
import json
from http.client import HTTPSConnection
from base64 import b64encode
import re
import time
import csv
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

#
# Defines Prism Central variables - update these with your HPOC details (uncomment for single cluster config)

# pcUserID = 'admin'
# pcPassword = 'nx2Tech123!'
# #prisCentIP = '10.38.3.73'
# prisCentIP = input("Enter Prism Central IP: ")

clusterdeets = '/Users/keith.olsen/Documents/GitHub/clusters.csv' # Path to csv file with cluster info

# Reads in cluster details from csv file

with open(clusterdeets) as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    next(readCSV)
    for row in readCSV:
        prismIP = (row[0])
        #print(prisCentIP)
        prismUserID = (row[1])
        #print(pcUserID)
        prismPassword = (row[2])
        #print(pcPassword)
        Annotation = (row[3])
        IMGname = (row[4])
        IMGtype = (row[5])
        IMGurl = (row[6])



        # This sets up the https connection

        c = HTTPSConnection(prismIP)


        # # Creates encoded Authorization value

        userpass = prismUserID + ":" + prismPassword
        buserAndPass = b64encode(userpass.encode("ascii"))
        authKey = (buserAndPass.decode("ascii"))

        headers = {
            'Content-Type': "application/json",
            'Authorization': "Basic " + authKey,
            'cache-control': "no-cache"
        }

        # # Defines base url for API calls

        baseurl = "https://" + prismIP + ":9440/PrismGateway/services/rest/v2.0/"

        # Get container list

        CTRlist = requests.request("GET", baseurl + "storage_containers", headers=headers, verify=False).json()

        json_CTRlist = json.dumps(CTRlist)

        for each in CTRlist['entities']:
            if (each['name']) == "Default":
                CTRuuid = (each['storage_container_uuid'])
                CTRname = (each['name'])
                CTRid = (each['id'])
                IMGpayload = {
                        "annotation": Annotation,
                        "image_import_spec": {
                        "storage_container_uuid": CTRuuid,
                        "storage_container_name": CTRname,
                        "storage_container_id": CTRid,
                        "url": IMGurl
                        },
                        "image_type": IMGtype,
                        "name": IMGname
                    }
                print (IMGpayload)


        json_IMGpayload = json.dumps(IMGpayload)

        print(json_IMGpayload)

        response = requests.request("POST", baseurl + "images/", headers=headers, data=json_IMGpayload, verify=False).json()
        print(response)

        #print(json_APPlist)


