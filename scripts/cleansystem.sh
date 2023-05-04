#!/bin/bash

df -h | grep -E "[s|v]da"
sudo pacman -Rsn $(pacman -Qdtq)
sudo pacman -Scc 2> /dev/null

sudo journalctl --disk-usage
sudo journalctl --vacuum-size=5M
sudo journalctl --verify
sudo journalctl --disk-usage

sudo find /var/log -type f -regex ".*\.gz$" -delete 2> /dev/null
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete 2> /dev/null

[ -f /usr/bin/btrfs ] && (sudo btrfs scrub start /; echo "Waiting 30 seconds..."; sleep 30; sudo btrfs scrub status /)

df -h | grep -E "[s|v]da"
