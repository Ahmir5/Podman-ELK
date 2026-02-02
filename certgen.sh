#!/bin/bash
set -e
mkdir ./certs
cd ./certs
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1826 -out ca.crt -subj "/CN=ELK PROJECT/C=US/ST=a/L=b/O=c"
openssl req -new -nodes -newkey rsa:4096 -keyout kib01.key -out kib01.csr -subj "/CN=kib01/C=US/ST=a/L=b/O=c"
cat > kib01.ext <<EOF
subjectAltName=DNS:kib01
EOF
openssl x509 -req -in kib01.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kib01.crt -days 30 -sha256 -extfile kib01.ext
cd ..