#!/usr/bin/env bash

# source: http://blog.amigapallo.org/2016/04/14/alertmanager-docker-container-self-signed-smtp-server-certificate/

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $(which openssl) ]]; then
  echo "INFO" "Checking SSL requirements: OpenSSL installed"
else
  echo "INFO" "Error: SSLFrameworkEnabled requires openssl to be installed"
  exit 1
fi

if [[ $(which keytool) ]]; then
  echo "INFO" "Checking SSL requirements: keytool installed"
else
  echo "INFO" "Error: SSLFrameworkEnabled requires keytool to be installed"
  exit 1
fi

# Prepare
rm -rf $CWD/keys
mkdir -p $CWD/keys

# Create a root private key
openssl genrsa -out $CWD/keys/cert.ca.key 2048

# Create a self-signed root certificate
openssl req -x509 -new -nodes -key $CWD/keys/cert.ca.key \
    -days 3650 -out $CWD/keys/postfix.ca.crt \
    -subj "/C=US/ST=New York/L=New York/O=Hyena Den/CN=tonydark.lan"

# Create a private key for the final certificate
openssl genrsa -out $CWD/keys/postfix.key 2048

# Create a certificate signing request
openssl req -new -key $CWD/keys/postfix.key \
    -out $CWD/keys/cert.csr \
    -subj "/C=FI/ST=Uusimaa/L=New York/O=Hyena Den/CN=tonydark.lan"

# Create a server certificate based on the root CA certificate
# and the root private key (and add extensions)
openssl x509 -req -in $CWD/keys/cert.csr \
    -CA $CWD/keys/postfix.ca.crt \
    -CAkey $CWD/keys/cert.ca.key -CAcreateserial \
    -out $CWD/keys/postfix.crt \
    -days 3650 -extensions v3_req -extfile $CWD/extfile.cnf

echo -e "\nUse postfix.ca.crt, postfix.key and postfix.crt\n"
