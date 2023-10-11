#!/bin/bash

#Revert snapshot to real_root as /
sudo mount $(df -Th | grep btrfs | grep /$ | cut -d' ' -f 1) /mnt && cd /mnt
sudo mv @root letstest_root && sudo mv real_root @root
sudo mv @home letstest_home && sudo mv real_home @home
cd / && sudo umount /mnt && sudo reboot
