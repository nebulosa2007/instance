#!/bin/bash

df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"
sudo pacman -Rsn $(pacman -Qdtq)
sudo rm -f $(awk '/Cache/ {print $3}' /etc/pacman.conf)/*.pkg.tar.{zst,zst.sig}

sudo journalctl --disk-usage
sudo journalctl --vacuum-size=5M
sudo journalctl --verify
sudo journalctl --disk-usage

sudo find /var/log -type f -regex ".*\.gz$" -delete 2> /dev/null
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete 2> /dev/null

#CLEANING PIKAUR CACHE
find /home/$(whoami)/.cache/pikaur/build -delete 2> /dev/null
find /home/$(whoami)/.cache/pikaur/pkg -delete 2> /dev/null

if [ -x "$(command -v btrfs)" ]; then
  sudo btrfs scrub start /
  for i in . . . . .; do echo -n $i; sleep 1; done
  while [ "$(sudo btrfs scrub status / | grep 'running')" != "" ] ; do echo -n "." ; sleep 1; done; echo
  sudo btrfs scrub status /
fi

df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"
