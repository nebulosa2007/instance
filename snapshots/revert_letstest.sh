#!/bin/bash

#Revert snapshot to real_root as /
sudo mount /dev/sda1 /mnt && cd /mnt
sudo mv @root letstest_root && sudo mv real_root @root
cd / && sudo umount /mnt && sudo reboot
