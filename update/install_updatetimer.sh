#!/bin/bash

sudo cp /home/$(whoami)/instance/update/updpkgs.sh     /usr/bin/updpkgs
sudo cp /home/$(whoami)/instance/update/update.service /lib/systemd/system/update.service
sudo cp /home/$(whoami)/instance/update/update.timer   /etc/systemd/system/update.timer
sudo systemctl daemon-reload
sudo systemctl enable --now update.timer
