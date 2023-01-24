#!/bin/bash

SUBVOL="@archiso"
ISO="archlinux-x86_64.iso"
MIRROR="https://mirror.yandex.ru/archlinux/iso/latest/"
FOLDER="/mnt/archiso"

cd $HOME/Downloads
echo "Downloading $ISO from " $(echo $MIRROR | cut -d"/" -f3) "..."
curl -L -O -C - "$MIRROR$ISO"
curl -s $MIRROR"sha256sums.txt" | grep $ISO | sha256sum -c --

if [ $? -eq 0 ]
then
    # make subvolume if it isn't exist and update grub entry:
    if [ "$(sudo btrfs subvolume list / | awk '/level 5/ && /'$SUBVOL'/ {print $NF}'| head -n1)" == "" ]
    then
        sudo mount /dev/sda1 /mnt && cd /mnt && sudo btrfs subvolume create $SUBVOL && cd / && sudo umount /mnt
        sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=2/' /etc/default/grub
        cat $HOME/instance/snapshots/40_custom.menuentry | sudo tee -a /etc/grub.d/40_custom > /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    sudo mkdir -p $FOLDER
    sudo mount -o noatime,compress=zstd,space_cache=v2,discard=async,subvol=$SUBVOL /dev/sda1 $FOLDER
    sudo curl -o "$FOLDER/$ISO" "FILE://$HOME/Downloads/$ISO"
    cd $FOLDER
    curl -s $MIRROR"sha256sums.txt" | grep $ISO | sha256sum -c --
    cd / && sudo umount $FOLDER && sudo rm -r $FOLDER
    rm $HOME/Downloads/$ISO
fi
