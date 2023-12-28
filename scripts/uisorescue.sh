#!/bin/bash

MIRROR="mirror.ams1.nl.leaseweb.net"
SUBVOL="@archiso"
ISO="archlinux-x86_64.iso"
FOLDER="/mnt/archiso"

ROOTDRIVE=$(mount | grep -Po '^.*(?= on \/ type btrfs)')

[ "$ROOTDRIVE" == "" ] && echo "This script works only with BTRFS" && exit 1
[ ! -e /etc/default/grub ] && echo "This script works only with GRUB" && exit 1


function writetogrub(){
    sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=1/' /etc/default/grub
    cat << EOF > /tmp/40_custom
menuentry 'Boot from archlinux.iso' {
    load_video
    set gfxpayload=keep
    insmod gzio
    insmod part_gpt
    insmod btrfs
    insmod loopback
    probe -u \$root --set=rootuuid
    set imgdevpath="/dev/disk/by-uuid/\$rootuuid"
    set isofile='/@archiso/archlinux-x86_64.iso'
    loopback loop \$isofile
    linux (loop)/arch/boot/x86_64/vmlinuz-linux img_dev=\$imgdevpath img_loop=\$isofile earlymodules=loop
    initrd (loop)/arch/boot/x86_64/initramfs-linux.img
}
EOF
    if [ $(cat /etc/grub.d/40_custom | wc -l) -eq 5 ]; then
       cat /tmp/40_custom | sudo tee -a /etc/grub.d/40_custom > /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg
       rm /tmp/40_custom
    fi
}


function checkiso(){
    curl -s "https://$MIRROR/archlinux/iso/latest/sha256sums.txt" | grep $ISO | sha256sum -c --
}


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$SUBVOL)" == "" ]; then
    sudo mount $ROOTDRIVE /mnt
    cd /mnt && sudo btrfs subvolume create $SUBVOL && cd /
    sudo umount /mnt && writetogrub || echo "Error of creating $SUBVOL!"
fi


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$SUBVOL)" != "" ]; then
    sudo mkdir -p $FOLDER && sudo mount -o compress=zstd:3,subvol=$SUBVOL $ROOTDRIVE $FOLDER
    cd $FOLDER
    if checkiso; then
        echo "The system already has latest iso image of Archlinux. Nothing to do"
    else
        echo "Downloading $ISO from $MIRROR ..."
        cd /home/$(whoami)
        curl -L -O -C - "https://$MIRROR/archlinux/iso/latest/$ISO"
        sudo curl -o "$FOLDER/$ISO" "FILE:///home/$(whoami)/$ISO"
        checkiso && rm /home/$(whoami)/$ISO || echo "Checksum error!"
    fi
    cd / && sudo umount $FOLDER && sudo rm -r $FOLDER
fi
