#!/bin/bash

set -e

CERT_FOLDER="/certs"

function log() {
  echo "$(date +%Y-%m-%dT%H:%M:%S) : $1"
}

if [ -z "$DH_LENGTH" ]; then
  DH_LENGTH=2048
fi

DH_FILE_PATH="$CERT_FOLDER/dhparam.pem"
if [ ! -e "$DH_FILE_PATH" ]; then
  log "Generate Diffie-Hellman file with length: $DH_LENGTH"
  log "It can takes several minutes"
  openssl dhparam -out "$DH_FILE_PATH" $DH_LENGTH
  log "Diffie-Hellman file generated"
else
  log "Diffie-Hellman file already exists"
fi

exit 0
