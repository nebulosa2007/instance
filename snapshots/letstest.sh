#!/bin/bash

#Make a test snapshot
sudo mount /dev/sda1 /mnt && cd /mnt
sudo btrfs subvolume snapshot @root letstest_root

#Change @root to snapshot as /
sudo mv @root real_root && sudo mv letstest_root @root
cd / && sudo umount /mnt
sudo reboot
