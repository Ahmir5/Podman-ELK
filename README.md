# Podman ELK Deployment

ELK STACK

An ELK stack is a combination of Elasticsearch, logstash, and kibana 
essentially comunicating with each other to operate on a higher level of showing what
data is being transported through the network.
____________________________________________________________________________________

'''Quick Start'''

##Needed folders/files
- ".env" 

##Steps to start up ELK, run all commands seperately 

```

###DOWNLOAD pwgen
sudo dnf install pwgen


###1 First clone the repo through SSH

###2 CD into the repo
cd Podman-Elk

###3 Generate ssl certificates
#### run certgen.sh

###4 run the script
./group_elk.sh


## FINISHED. YOU'RE ELK STACK IS RUNNING. CHECK IT OUT
### See if all containers are up and running  
podman ps

### See if logstash is up and CONNECTS to Elasticsearch successfully
podman logs logstash01

### Send a test log to verify working ELK stack
echo '{"message": "Hello from TCP test", "level": "info", "timestamp": "'$(date -Is)'"}' | nc localhost 50000

###9 GO to the browser and search in the address bar "https://localhost:5601/"

###14 Get the credentials from file .env for ELASTIC_USERNAME and ELASTIC_PASSWORD
cat .env 

###15 Click on the 3 bars on the top left, go to "Stack Management", Then to "Index Management"

###16 Here your log should appear

```
