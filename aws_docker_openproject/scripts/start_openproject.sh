#!/bin/bash

DIR_PGDATA=$1
DIR_LOGS=$2
DIR_STATIC=$3
SECRET=$4

sudo mkdir -p "$DIR_PGDATA"
sudo mkdir -p "$DIR_LOGS"
sudo mkdir -p "$DIR_STATIC"

sudo docker run -d -p 80:80 --name openproject -e SECRET_KEY_BASE="$SECRET" \
  -v "$DIR_PGDATA":/var/lib/postgresql/9.6/main \
  -v "$DIR_LOGS":/var/log/supervisor \
  -v "$DIR_STATIC":/var/db/openproject \
  openproject/community:8
