#!/bin/bash

df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"

# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Removing_unused_packages_(orphans)
sudo pacman -Rsn $(pacman -Qdtq)

# https://wiki.archlinux.org/title/Pacman#Package_cache_directory
# In case Cache folder is '/tmp' to do not flush other files
sudo rm -f $(awk '/Cache/ {print $3}' /etc/pacman.conf)/*.pkg.tar.{zst,zst.sig}

# https://wiki.archlinux.org/title/Systemd/Journal#Clean_journal_files_manually
sudo journalctl --disk-usage
sudo journalctl --vacuum-size=5M
sudo journalctl --verify
sudo journalctl --disk-usage

# Remove old log files
sudo find /var/log -type f -regex ".*\.gz$" -delete 2> /dev/null
sudo find /var/log -type f -regex ".*\.[0-9]$" -delete 2> /dev/null

# Cleaning pikaur cache
find /home/$(whoami)/.cache/pikaur/build -delete 2> /dev/null
find /home/$(whoami)/.cache/pikaur/pkg -delete 2> /dev/null

# Cleaning HOME folder
[ -d "$HOME/.thumbnails" ] && { find "$HOME/.thumbnails" -type f -atime +7 -delete; find "$HOME/.thumbnails" -empty -type d -atime +7 -delete ; }
[ -d "$HOME/.cache" ]      && { find "$HOME/.cache" -type f -atime +7 -delete;      find "$HOME/.cache" -empty -type d -atime +7 -delete ; }

# https://wiki.archlinux.org/title/Btrfs#Scrub
if [ -x "$(command -v btrfs)" ]; then
  sudo btrfs scrub start /
  for i in . . . . .; do echo -n $i; sleep 1; done
  while [ "$(sudo btrfs scrub status / | grep 'running')" != "" ] ; do echo -n "." ; sleep 1; done; echo
  sudo btrfs scrub status /
fi

#todo https://wiki.archlinux.org/title/Btrfs#Balance

df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"
