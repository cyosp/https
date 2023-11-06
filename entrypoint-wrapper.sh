#!/bin/sh

echo "create certificate"

cron && /docker-entrypoint.sh "$@"
