#!/bin/bash

set -e

CERT_FOLDER="/certs"
CONF_FOLDER="/conf"

ln -s $CONF_FOLDER/* /etc/nginx/conf.d/

function log() {
  echo "$(/usr/bin/date +%Y-%m-%dT%H:%M:%S) : $1"
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
    /usr/bin/mkdir -p $CERT_HOST_DIR
    /usr/bin/openssl genrsa -out $CERT_HOST_CERT_KEY_FILE_PATH 2048 2>&1
    /usr/bin/openssl req -new -key $CERT_HOST_CERT_KEY_FILE_PATH \
            -out CERT_HOST_CERT_CSR_FILE_PATH \
            -subj "/C=XX/ST=State/L=City/O=Organization/OU=IT/CN=$domain" 2>&1
    /usr/bin/openssl x509 -req -days 365 -in CERT_HOST_CERT_CSR_FILE_PATH \
            -signkey $CERT_HOST_CERT_KEY_FILE_PATH \
            -out $CERT_HOST_CERT_PEM_FILE_PATH 2>&1
    /usr/bin/rm CERT_HOST_CERT_CSR_FILE_PATH
    /usr/bin/cp $CERT_HOST_CERT_PEM_FILE_PATH $CERT_HOST_DIR/fullchain.pem
    log "[$domain] Success"
  else
    log "[$domain] certificate already exists"
  fi

  path="${host}_AND_PATH"
  path=${!path}
  domainAndPath="${domain}$path"

  log "[$domainAndPath] Create nginx configuration"

  server="${host}_TO"

  withHref="${host}_WITH_HREF"
  withHref=${!withHref}

  withHrefComment="#"
  if [ -n "$withHref" ]; then
    withHrefComment=""
  fi

  DOMAIN_LOWER_CASE=$(echo $domain | /usr/bin/tr '[:upper:]' '[:lower:]')
  DOMAIN_FOLDER=$CONF_FOLDER/$DOMAIN_LOWER_CASE
  /usr/bin/mkdir -p $DOMAIN_FOLDER

  PATH_UNDERSCORE=${path//\//_}

  basicAuthUserNameAndPassword="${host}_BASIC_AUTH_USERNAME_AND_PASSWORD"
  basicAuthUserNameAndPassword=${!basicAuthUserNameAndPassword}

  basicAuthConfigurationValue="# No basic authentification"
  if [ -n "${basicAuthUserNameAndPassword}" ]; then
    HTPASSWORD_FILE="$DOMAIN_FOLDER/$PATH_UNDERSCORE.htpasswd"
    echo "${basicAuthUserNameAndPassword}" > $HTPASSWORD_FILE
    basicAuthConfigurationValue="auth_basic 'Restricted area'; auth_basic_user_file $HTPASSWORD_FILE;"
  fi

  export DOMAIN=$domain
  export PATH=$path
  /usr/bin/envsubst '$DOMAIN' < /tmp/domain-base.template > "$CONF_FOLDER/$DOMAIN_LOWER_CASE.conf"
  if [ -n "$path" ]; then
      /usr/bin/envsubst '$PATH' < /tmp/domain-path-http.template > "$DOMAIN_FOLDER/$PATH_UNDERSCORE-http_redirect.conf"
  fi

  export SERVER=${!server}
  export WITH_HREF_COMMENT=${withHrefComment}
  export WITH_HREF=$withHref
  export BASIC_AUTH=${basicAuthConfigurationValue}
  /usr/bin/envsubst '$DOMAIN,$PATH,$SERVER,$WITH_HREF_COMMENT,$WITH_HREF,$BASIC_AUTH' < /tmp/domain-path.template > "$DOMAIN_FOLDER/$PATH_UNDERSCORE.conf"
  log "[$domainAndPath] Success"
done

/usr/sbin/nginx -s reload 2>&1

exit 0
