#!/bin/bash

# https://docs.docker.com/engine/daemon/remote-access/

CONF_DIR="/etc/systemd/system/docker.service.d"
CONF_FILE="/etc/systemd/system/docker.service.d/override.conf"
sudo mkdir -p $CONF_DIR
echo "[Service]" >> $CONF_FILE
echo "ExecStart=" >> $CONF_FILE
echo "ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
" >> $CONF_FILE

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo netstat -lntp | grep dockerd