#!/bin/false
# shellcheck shell=bash

#Tg daily statistic  module of Instance project

#IMPORTANT: Only for one partition systems. Use cp instead ln below:
sudo ln -sf "$PATHINSTANCE"/etc/tgdailystat/tgdailystat.sh -t /usr/local/bin
sudo cp "$PATHINSTANCE"/etc/tgdailystat/tgdailystat.{service,timer} -t /etc/systemd/system
sudo systemctl daemon-reload

#Check if any "wait-online-service" is working. Credits: https://wiki.archlinux.org/title/Systemd-networkd#systemd-networkd-wait-online
#systemctl is-enabled NetworkManager-wait-online.service systemd-networkd-wait-online.service

sudo systemctl enable --now tgdailystat.timer
