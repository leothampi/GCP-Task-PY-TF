import requests
import json

metadata_server = "http://metadata/computeMetadata/v1/instance/"
metadata_flavor = {'Metadata-Flavor' : 'Google'}

#gce_id = requests.get(metadata_server + 'id', headers = metadata_flavor).text
#gce_name = requests.get(metadata_server + 'hostname', headers = metadata_flavor).text
#gce_machine_type = requests.get(metadata_server + 'machine-type', headers = metadata_flavor).text
#gce_cpu_platform = requests.get(metadata_server + 'cpu-platform', headers = metadata_flavor).text
#print (gce_id)
#print (gce_name)
#print (gce_cpu_platform)
#metadata_server1 = "http://metadata.google.internal/computeMetadata/v1/instance/disks/ -H 'Metadata-Flavor' : 'Google'"
   

out = requests.get(metadata_server).text
#print (out.split('\n'))
lstval = out.split('\n')
#print (lstval)
#print (metadata_server1)

num =len(lstval) 
#print (num)

# Dictinary initilization 
test_dict ={}

#write the date to dictinary 

for i in range(0,num):

    test_dict[lstval[i]] = requests.get(metadata_server + "" +lstval[i] +"", headers = metadata_flavor).text

    #print (test_dict)

    # Write the dic values to new dic
    json_str = json.dumps(test_dict)

    # Open a file in write mode
    with open('test_dict.json', 'w') as file:

    # Write the JSON string to the file
        file.write(json_str)
