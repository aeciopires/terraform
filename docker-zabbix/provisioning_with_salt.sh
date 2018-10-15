#!/bin/bash

###########
# Variables
###########
SALT=/usr/bin/salt

######
# MAIN
######

# Install SaltStack
# Only Ubuntu 18.04
# wget -O - https://repo.saltstack.com/apt/ubuntu/18.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
if [ ! -f $SALT ] ; then
  echo "[WARNING] Nao encontrei o(s) arquivo(s) \"$SALT\""
  echo "Tentarei instalar..."
  curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh;
  sudo sh /tmp/install_salt.sh -P -M;
  if [ ! -f $SALT ] ; then
    echo "[ERROR] Nao encontrei o(s) arquivo(s) \"$SALT\""
    exit 4
  fi
fi

# Copies files
sudo mkdir -p /srv
sudo cp -R salt /srv
sudo cp -R pillar /srv

# Provisioning with SaltStack
sudo salt-call --local --pillar-root=/srv/pillar/ --file-root=/srv/salt/ state.apply;
