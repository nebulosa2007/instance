#!/bin/bash

sudo ln -s /home/$(whoami)/instance/update/updpkgs.sh /usr/bin/updpkgs
sudo ln -s /home/$(whoami)/instance/update/update.service /lib/systemd/system/update.service
sudo ln -s /home/$(whoami)/instance/update/update.timer /lib/systemd/system/update.timer
sudo systemctl daemon-reload
sudo systemctl enable --now update.timer