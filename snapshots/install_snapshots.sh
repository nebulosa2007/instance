#!/bin/bash

sudo mkdir -p /etc/pacman.d/hooks
sudo sudo ln -s /home/$(whoami)/instance/snapshots/snaproot.sh /usr/bin/snaproot
sudo cp /home/$(whoami)/instance/snapshots/01-btrfs-autosnap.hook /etc/pacman.d/hooks/01-btrfs-autosnap.hook
