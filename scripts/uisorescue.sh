#!/bin/bash

source /etc/instance.conf
SUBVOL="@archiso"
ISO="archlinux-x86_64.iso"
MIRROR="https://mirror.ams1.nl.leaseweb.net/archlinux/iso/latest/"
FOLDER="/mnt/archiso"

ALLDONE=0
ROOTDRIVE=$(df -Th | grep btrfs | grep /$ | cut -d' ' -f 1)

#Checker if all already done
if [ "$(sudo btrfs subvolume list / | awk '/level 5/ && /'$SUBVOL'/ {print $NF}'| head -n1)" != "" ]
then
    sudo mkdir -p $FOLDER && sudo mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=$SUBVOL $ROOTDRIVE $FOLDER
    cd $FOLDER && curl -s $MIRROR"sha256sums.txt" | grep $ISO | sha256sum -c -- && echo "System has already latest iso image of Archlinux. Nothing to do.." && ALLDONE=1
    cd / && sudo umount $FOLDER && sudo rm -r $FOLDER
    if [ $(cat /etc/grub.d/40_custom | wc -l) -eq 5 ]
    then
        sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=1/' /etc/default/grub
        cat $PATHINSTANCE/etc/40_custom.menuentry | sudo tee -a /etc/grub.d/40_custom > /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    [ $ALLDONE -eq 1 ] && exit 1
fi

cd /home/$(whoami)
echo "Downloading $ISO from " $(echo $MIRROR | cut -d"/" -f3) "..."
curl -L -O -C - "$MIRROR$ISO"
curl -s $MIRROR"sha256sums.txt" | grep $ISO | sha256sum -c --

if [ $? -eq 0 ]
then
    # make subvolume if it isn't exist and update grub entry:
    if [ "$(sudo btrfs subvolume list / | awk '/level 5/ && /'$SUBVOL'/ {print $NF}'| head -n1)" == "" ]
    then
        sudo mount $ROOTDRIVE /mnt && cd /mnt && sudo btrfs subvolume create $SUBVOL && cd / && sudo umount /mnt
        if [ $? -eq 0 ]
        then
            sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=1/' /etc/default/grub
            cat $PATHINSTANCE/etc/40_custom.menuentry | sudo tee -a /etc/grub.d/40_custom > /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg
        else
            echo "Error of creating $SUBVOL"
            exit 1
        fi
    fi
    sudo mkdir -p $FOLDER && sudo mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=$SUBVOL $ROOTDRIVE $FOLDER
    if [ $? -eq 0 ]
    then
        sudo curl -o "$FOLDER/$ISO" "FILE:///home/$(whoami)/$ISO"
        cd $FOLDER && curl -s $MIRROR"sha256sums.txt" | grep $ISO | sha256sum -c --
        cd / && sudo umount $FOLDER && sudo rm -r $FOLDER
        rm /home/$(whoami)/$ISO
    else
        echo "Error of mounting $SUBVOL"
    fi
fi
