#!/bin/bash

source /etc/instance.conf
SUBVOL="@archiso"
ISO="archlinux-x86_64.iso"
MIRROR="mirror.ams1.nl.leaseweb.net"
FOLDER="/mnt/archiso"

ROOTDRIVE=$(mount | grep -Po '^.*(?= on \/ type btrfs)')

[ "$ROOTDRIVE" == "" ] && echo "This script works only with BTRFS" && exit 1
[ ! -e /etc/default/grub ] && echo "This script works only with GRUB" && exit 1


function writetogrub(){
    sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=1/' /etc/default/grub
    if [ $(cat /etc/grub.d/40_custom | wc -l) -eq 5 ]
    then
       cat $PATHINSTANCE/etc/40_custom.menuentry | sudo tee -a /etc/grub.d/40_custom > /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
}


function checkiso(){
	curl -s "https://"$MIRROR"/archlinux/iso/latest/sha256sums.txt" | grep $ISO | sha256sum -c --
}


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$SUBVOL)" == "" ]
then
	sudo mount $ROOTDRIVE /mnt
	cd /mnt && sudo btrfs subvolume create $SUBVOL && cd /
	sudo umount /mnt && writetogrub || echo "Error of creating $SUBVOL!"
fi


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$SUBVOL)" != "" ]
then
    sudo mkdir -p $FOLDER && sudo mount -o compress=zstd:3,subvol=$SUBVOL $ROOTDRIVE $FOLDER
    cd $FOLDER
    if checkiso
    then
        echo "The system already has latest iso image of Archlinux. Nothing to do"
    else
        echo "Downloading $ISO from $MIRROR ..."
        cd /home/$(whoami)
        curl -L -O -C - "https://"$MIRROR"/archlinux/iso/latest/$ISO"
        sudo curl -o "$FOLDER/$ISO" "FILE:///home/$(whoami)/$ISO"
        checkiso && rm /home/$(whoami)/$ISO || echo "Checksum error!"
    fi
    cd / && sudo umount $FOLDER && sudo rm -r $FOLDER
fi
