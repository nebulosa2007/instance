#!/bin/bash

sudo mkdir -p /etc/pacman.d/hooks
sudo sudo ln -s /home/$(whoami)/instance/snapshots/snaproot.sh /usr/bin/snaproot
sudo cp /home/$(whoami)/instance/snapshots/01-btrfs-autosnap.hook /etc/pacman.d/hooks/01-btrfs-autosnap.hook

#Cache cleaning for minimize size of snapshots
sudo rm -f /var/cache/pacman/pkg/*
sudo sed -i 's/#CacheDir    = \/var\/cache\/pacman\/pkg\//CacheDir     = \/tmp\//' /etc/pacman.conf

#TODO
http://wiki.rosalab.ru/ru/index.php/%D0%9F%D0%B5%D1%80%D0%B5%D0%BD%D0%BE%D1%81_%D1%81%D0%BD%D0%B0%D0%BF%D1%88%D0%BE%D1%82%D0%BE%D0%B2(snapshots)_btrfs_%D0%BD%D0%B0_%D0%B4%D1%80%D1%83%D0%B3%D0%BE%D0%B9_%D1%80%D0%B0%D0%B7%D0%B4%D0%B5%D0%BB_%D0%B2_%D0%BE%D1%82%D0%B4%D0%B5%D0%BB%D1%8C%D0%BD%D0%BE%D0%BC_%D1%84%D0%B0%D0%B9%D0%BB%D0%B5
