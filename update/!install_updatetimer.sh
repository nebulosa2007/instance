#!/bin/bash

sudo cp /home/$(whoami)/instance/update/updpkgs.sh     /usr/bin/updpkgs
sudo cp /home/$(whoami)/instance/update/update.service /lib/systemd/system/update.service
sudo cp /home/$(whoami)/instance/update/update.timer   /lib/systemd/system/update.timer
sudo systemctl daemon-reload

#Check if any "wait-online-service" is working. Credits: https://wiki.archlinux.org/title/Systemd-networkd#systemd-networkd-wait-online
systemctl is-enabled NetworkManager-wait-online.service systemd-networkd-wait-online.service

sudo systemctl enable --now update.timer
