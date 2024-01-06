#!/bin/bash

mirror="mirror.ams1.nl.leaseweb.net"
subvol="@archiso"
iso="archlinux-x86_64.iso"
folder="/mnt/archiso"

rootdrive=$(mount | grep -Po '^.*(?= on \/ type btrfs)')

[ "$rootdrive" == "" ] && echo "This script works only with BTRFS" && exit 1
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
    curl -s "https://$mirror/archlinux/iso/latest/sha256sums.txt" | grep $iso | sha256sum -c --
}


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$subvol)" == "" ]; then
    sudo mount $rootdrive /mnt
    cd /mnt && sudo btrfs subvolume create $subvol && cd /
    sudo umount /mnt && writetogrub || echo "Error of creating $subvol!"
fi


if [ "$(sudo btrfs subvolume list / | grep 'top level [0-9] path '$subvol)" != "" ]; then
    sudo mkdir -p $folder && sudo mount -o compress=zstd:3,subvol=$subvol $rootdrive $folder
    cd $folder
    if checkiso; then
        echo "The latest iso image of Archlinux is already on the system. Nothing to do."
    else
        echo "Downloading $iso from $mirror ..."
        cd /home/$(whoami)
        curl -L -O -C - "https://$mirror/archlinux/iso/latest/$iso"
        sudo curl -o "$folder/$iso" "FILE:///home/$(whoami)/$iso"
        checkiso && rm /home/$(whoami)/$iso || echo "Checksum error!"
    fi
    cd / && sudo umount $folder && sudo rm -r $folder
fi
