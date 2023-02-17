#!/bin/bash

#Fix subid 
sudo sed -i 's/subvolid=256,//;s/subvolid=257,//' /etc/fstab
#Make a test snapshot of @root and @home
sudo mount /dev/sda1 /mnt && cd /mnt
sudo btrfs subvolume delete letstest_root && sudo btrfs subvolume delete letstest_home
sudo btrfs subvolume snapshot @root letstest_root && sudo btrfs subvolume snapshot @home letstest_home

#Change @root to snapshot as /
sudo mv @root real_root && sudo mv letstest_root @root
sudo mv @home real_home && sudo mv letstest_home @home
cd / && sudo umount /mnt
sudo reboot
