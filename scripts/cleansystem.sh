#!/bin/bash

# pikaur -Syu --needed localepurge

df -h | grep -E "[s|v]da"
sudo pacman -Rsn $(pacman -Qdtq)
sudo pacman -Scc
sudo localepurge


sudo journalctl --disk-usage
sudo journalctl --vacuum-size=5M
sudo journalctl --verify
sudo journalctl --disk-usage

find /var/log -type f -regex ".*\.gz$" 2> /dev/null | sudo xargs rm -rf
find /var/log -type f -regex ".*\.[0-9]$" 2> /dev/null| sudo xargs rm -rf
find ~/.cache/* 2> /dev/null| sudo xargs rm -rf

df -h | grep -E "[s|v]da"
