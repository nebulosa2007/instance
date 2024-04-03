#!/bin/bash

# This script makes a BTRFS subvolume with latest Archlinux iso image and sets a new entry in GRUB menu
# which allows you to boot from iso image directly. Some kind of RescueDisk that hard to broke
# because it is not mounted in your daily work routine. Feel free to run this script once a month,
# script will update the iso image to the latest from the mirror.

# Requires: BTFRS, GRUB, curl, grep, sed, sha256sum, tee, cat, find

mirror="mirror.ams1.nl.leaseweb.net" # More mirrors can be found here: https://archlinux.org/download/
subvol="@archiso"
iso="archlinux-x86_64.iso"
folder="/mnt/archiso"

rootdrive=$(mount | grep -Po '^.*(?= on \/ type btrfs)')

[ "$rootdrive" == "" ] && echo "This script works only with BTRFS" && exit 1
[ ! -e /etc/default/grub ] && echo "This script works only with GRUB" && exit 1


function writetogrub(){
    sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=1/' /etc/default/grub # At least one second needed
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
    if [ "$(wc -l < /etc/grub.d/40_custom)" -eq 5 ]; then
       cat /tmp/40_custom | sudo tee -a /etc/grub.d/40_custom > /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg
       find /tmp/40_custom -delete
    fi
}


function checkiso(){
    curl -s "https://$mirror/archlinux/iso/latest/sha256sums.txt" | grep $iso | sha256sum -c --
}


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$subvol)" == "" ]; then
    sudo mount "$rootdrive" /mnt
    pushd "/mnt" > /dev/null && sudo btrfs subvolume create $subvol && popd > /dev/null /
    sudo umount /mnt && writetogrub || echo "Error of creating $subvol!"
fi


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$subvol)" != "" ]; then
    sudo mkdir -p $folder && sudo mount -o compress=zstd:3,subvol=$subvol "$rootdrive" $folder
    pushd "$folder" > /dev/null || exit 2
    if checkiso; then
        echo "The latest Archlinux iso image already exists on the system. Nothing to do."
    else
        echo "Downloading $iso from $mirror to $HOME..."
        builtin cd "$HOME" || exit 3
        curl -L -O -C - "https://$mirror/archlinux/iso/latest/$iso"
        sudo curl -o "$folder/$iso" "FILE:///home/$(whoami)/$iso"
        checkiso && find "$HOME"/$iso -delete || echo "Checksum error!"
    fi
    builtin cd / && sudo umount $folder && sudo find $folder -delete
    popd > /dev/null || exit 2
fi
