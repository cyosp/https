#!/bin/bash

set -e

CERT_FOLDER="/certs"

function log() {
  echo "$(date +%Y-%m-%dT%H:%M:%S) : $1"
}

if [ -z "$DH_LENGTH" ]; then
  DH_LENGTH=2048
fi

DH_FILE_PATH=$CERT_FOLDER/dhparam.pem
if [ ! -e $DH_FILE_PATH ]; then
  log "Generate Diffie-Hellman file with length: $DH_LENGTH; it can takes several minutes"
  openssl dhparam -out $DH_FILE_PATH $DH_LENGTH
  log "Success"
else
  log "Diffie-Hellman file already exists"
fi

HOSTS=$(env | grep _FROM_HOST | cut -d "=" -f1 | sed "s/_FROM_HOST$//")
for host in $HOSTS
do
  domain="${host}_FROM_HOST"
  domain=${!domain}

  CERT_HOST_DIR=$CERT_FOLDER/$domain
  CERT_HOST_CERT_PEM_FILE_PATH=$CERT_HOST_DIR/cert.pem
  CERT_HOST_CERT_KEY_FILE_PATH=$CERT_HOST_DIR/key.pem
  CERT_HOST_CERT_CSR_FILE_PATH=$CERT_HOST_DIR/cert.csr

  if [ ! -e $CERT_HOST_CERT_PEM_FILE_PATH ]; then
    log "[$domain] Create self-signed certificate"
    mkdir -p $CERT_HOST_DIR
    openssl genrsa -out $CERT_HOST_CERT_KEY_FILE_PATH 2048
    openssl req -new -key $CERT_HOST_CERT_KEY_FILE_PATH \
            -out CERT_HOST_CERT_CSR_FILE_PATH \
            -subj "/C=XX/ST=State/L=City/O=Organization/OU=IT/CN=$domain"
    openssl x509 -req -days 365 -in CERT_HOST_CERT_CSR_FILE_PATH \
            -signkey $CERT_HOST_CERT_KEY_FILE_PATH \
            -out $CERT_HOST_CERT_PEM_FILE_PATH
    rm CERT_HOST_CERT_CSR_FILE_PATH
    cp $CERT_HOST_CERT_PEM_FILE_PATH $CERT_HOST_DIR/fullchain.pem
    log "[$domain] Success"
  else
    log "[$domain] Self-signed certificate already exists"
  fi
done

exit 0
