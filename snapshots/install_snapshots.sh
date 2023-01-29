#!/bin/bash

sudo mkdir -p /etc/pacman.d/hooks
sudo sudo ln -s /home/$(whoami)/instance/snapshots/snaproot.sh /usr/bin/snaproot
sudo cp /home/$(whoami)/instance/snapshots/01-btrfs-autosnap.hook /etc/pacman.d/hooks/01-btrfs-autosnap.hook

#Cache cleaning for minimize size of snapshots
sudo rm -f /var/cache/pacman/pkg/*
sudo sed -i 's/#CacheDir    = \/var\/cache\/pacman\/pkg\//CacheDir     = \/tmp\//' /etc/pacman.conf
