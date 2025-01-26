#!/bin/false
# shellcheck shell=bash

#Updates module of Instance project

#IMPORTANT: Only for one partition systems. Use cp instead ln below:
sudo ln -sf "$PATHINSTANCE"/update/updpkgs.sh /usr/bin/updpkgs

sudo cp "$PATHINSTANCE"/update/update.{service,timer} -t /etc/systemd/system
sudo systemctl daemon-reload

#Check if any "wait-online-service" is working. Credits: https://wiki.archlinux.org/title/Systemd-networkd#systemd-networkd-wait-online
systemctl is-enabled NetworkManager-wait-online.service systemd-networkd-wait-online.service

sudo systemctl enable --now update.timer
