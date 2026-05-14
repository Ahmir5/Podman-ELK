#!/bin/bash
set -e
mkdir ./certs
cd ./certs
# Generate Certificate Authority private key 
openssl genrsa -out ca.key 4096
# Generate Certificate Authority certificate with the previous key
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1826 -out ca.crt -subj "/CN=ELK PROJECT/C=US/ST=a/L=b/O=c"
# Generate Certificate Signing Request for Kibana
openssl req -new -nodes -newkey rsa:4096 -keyout kib01.key -out kib01.csr -subj "/CN=kib01/C=US/ST=a/L=b/O=c"
# Configuration file containing certificate and request X.509 extensions to add. Here it stores the alternative name 
cat > kib01.ext <<EOF
subjectAltName=DNS:kib01
EOF
# Certificate Signing request which uses the CA certificate and CA private key to create the Kibana certificate file
openssl x509 -req -in kib01.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kib01.crt -days 30 -sha256 -extfile kib01.ext
cd ..