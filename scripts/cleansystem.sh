#!/bin/bash

df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"

# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Removing_unused_packages_(orphans)
sudo pacman -Rsn $(pacman -Qdtq)

# https://wiki.archlinux.org/title/Pacman#Package_cache_directory
# In case Cache folder is '/tmp' to do not wipe other files
sudo find $(grep -Po '(?<=CacheDir) *= *\K(\S+)' /etc/pacman.conf) -type f -name "*.pkg.tar.zst*" -delete 2> /dev/null

# https://wiki.archlinux.org/title/Systemd/Journal#Clean_journal_files_manually
sudo journalctl --disk-usage
sudo journalctl --vacuum-size=5M
sudo journalctl --verify
sudo journalctl --disk-usage

# Remove old log files
sudo find /var/log -type f -regex ".*\.gz$" -delete 2> /dev/null
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete 2> /dev/null

# Cleaning pikaur cache
[ -d "/home/$(whoami)/.cache/pikaur/build" ] && find /home/$(whoami)/.cache/pikaur/build -type f -delete 2> /dev/null
[ -d "/home/$(whoami)/.cache/pikaur/pkg" ]   && find /home/$(whoami)/.cache/pikaur/pkg   -type f -delete 2> /dev/null

# Cleaning HOME folder
[ -d "/home/$(whoami)/.thumbnails" ] && { find "/home/$(whoami)/.thumbnails" -type f -atime +7 -delete; find "/home/$(whoami)/.thumbnails" -empty -type d -atime +7 -delete ; }
[ -d "/home/$(whoami)/.cache" ]      && { find "/home/$(whoami)/.cache"      -type f -atime +7 -delete; find "/home/$(whoami)/.cache"      -empty -type d -atime +7 -delete ; }

# https://wiki.archlinux.org/title/Btrfs#Scrub
if [ -x "$(command -v btrfs)" ]; then
  sudo btrfs scrub start /
  for i in . . . . .; do echo -n $i; sleep 1; done
  while [ "$(sudo btrfs scrub status / | grep 'running')" != "" ] ; do echo -n "." ; sleep 1; done; echo
  sudo btrfs scrub status /
fi

df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"
