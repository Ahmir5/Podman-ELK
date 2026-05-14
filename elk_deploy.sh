#!/bin/bash

set -ea
touch .env
echo "ELASTIC_USERNAME=\"elastic\"" > .env
source .env

podman network create --ignore  elastic

# Generate Elastic passwords
ELASTIC_PASSWORD=$(pwgen -s 15 1)
sed -i '/^ELASTIC_PASSWORD=/d' .env
echo "ELASTIC_PASSWORD=$ELASTIC_PASSWORD" >> .env

# ElasticSearch container startup
podman run --name es01 --hostname es01 -d --env-file .env --net elastic -p 9200:9200 docker.elastic.co/elasticsearch/elasticsearch:9.0.1
# Checking for elastic search container for full functionality before continuing
until curl -k -s -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD https://localhost:9200/ | grep -i "tagline"; do
  echo "Waiting for Elasticsearch to respond..."
  sleep 5
done

# Set Kibana password
podman exec -it es01 \
/usr/share/elasticsearch/bin/elasticsearch-reset-password \
-u kibana_system -b
Kib_pass=$(podman exec -it es01 \
/usr/share/elasticsearch/bin/elasticsearch-reset-password \
-u kibana_system -b | tail -n1 | cut -d " " -f3)
sed -i "s/^elasticsearch.password:.*/elasticsearch.password: $Kib_pass/" kibana.yml

podman cp es01:/usr/share/elasticsearch/config/certs/http_ca.crt ./certs/
chmod -R +r ./certs
# Kibana container startup
podman run -d --name kib01 --hostname kib01 --env-file .env --net elastic -p 5601:5601 \
-v $(pwd)/certs/:/usr/share/kibana/config/certs/:z \
-v $(pwd)/kibana.yml:/usr/share/kibana/config/kibana.yml:Z \
docker.elastic.co/kibana/kibana:9.0.1

# Logstash container startup
touch logstash.conf

cat <<EOF > logstash.conf 
input {
  beats {
    port => 5044
  }

  tcp {
    port => 50000
    codec => "json"
  }
}

output {
  elasticsearch {
    hosts => ["https://es01:9200/"]
    index => "logstash-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "\${ELASTIC_PASSWORD}"
    ssl_enabled => true
    ssl_certificate_authorities => "/usr/share/logstash/certs/http_ca.crt"
  }
}
EOF

podman run -d --name logstash01 --hostname logstash01 --env-file .env --net elastic -p 50000:50000 -v $(pwd)/certs/http_ca.crt:/usr/share/logstash/certs/http_ca.crt:z \
-v $(pwd)/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:Z docker.elastic.co/logstash/logstash:9.0.1 