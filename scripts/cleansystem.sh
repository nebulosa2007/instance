#!/bin/bash

df -h | grep -E "[s|v]da"
sudo pacman -Rsn $(pacman -Qdtq)
sudo rm -f $(awk '/Cache/ {print $3}' /etc/pacman.conf)/*.pkg.tar.zst

sudo journalctl --disk-usage
sudo journalctl --vacuum-size=5M
sudo journalctl --verify
sudo journalctl --disk-usage

sudo find /var/log -type f -regex ".*\.gz$" -delete 2> /dev/null
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete 2> /dev/null

#CLEANING PIKAUR CACHE
find /home/$(whoami)/.cache/pikaur/build -delete 2> /dev/null
find /home/$(whoami)/.cache/pikaur/pkg -delete 2> /dev/null

[ -x "$(command -v btrfs)" ] && (sudo btrfs scrub start /; echo "Waiting 30 seconds..."; sleep 30; sudo btrfs scrub status /)

df -h | grep -E "[s|v]da"
