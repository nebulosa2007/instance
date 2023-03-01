#!/bin/bash

sudo cp /home/$(whoami)/instance/wireguard/stat/wg-stat.sh /usr/bin/wg-stat
sudo cp /home/$(whoami)/instance/wireguard/stat/wgstat.service /lib/systemd/system/wgstat.service
sudo cp /home/$(whoami)/instance/wireguard/stat/wgstat.timer /lib/systemd/system/wgstat.timer
sudo systemctl daemon-reload
sudo systemctl enable --now wgstat.timer
