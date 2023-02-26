#!/bin/bash

sn=10
ROOTVOLUME="@root"
ACTION=$(grep "\[PACMAN\]" /var/log/pacman.log | tail -1 | cut -d" " -f3-)

red='\033[0;31m'
nc='\033[0m'
yellow='\033[0;33m'

#Root subvolume device
rsvdv="$(df -Th | grep btrfs | grep /$ | cut -d' ' -f 1)"

#Current timestamp
cdt=`date +"%Y-%b-%d-%T"`

#Root subvolume
rsv="$(btrfs subvolume list / | awk '/level 5/ && /'$ROOTVOLUME'/ {print $NF}'| head -n1)"

#Number of root snapshots
rsl="$(btrfs subvolume list / | awk '/root-snapshot/' | wc -l)"

#Oldest root snapshot
ors="$(btrfs subvolume list / | awk '/root-snapshot/ {print $NF}' | head -n1)"

#mount Root subvolume device to /mnt
if [ -e "$rsvdv" ]; then
    mount $rsvdv /mnt
    #printf "${yellow} mounted $rsvdv to /mnt${nc}\n"
else
    printf "${red} no btrfs drives found${nc}\n" && exit 1
fi

cd /mnt

# Check that root subvolume is found...
if [ -e "$rsv" ]; then
    :
    #printf "${yellow} root subvolume found... $rsv${nc}\n"
else
    printf "${red} no root subvolume found... exiting${nc}\n" && cd $HOME && umount /mnt && exit 1
fi

# Create snapshot of root subvolume and place in snapshot subvolume with date attached...
echo "["root-snapshot-$cdt"]" $ACTION
btrfs subvolume snapshot $rsv root-snapshot-$cdt

#remove a snapshot if there are more than $sn
if [ "$rsl" -ge "$sn"  ]; then
	#printf "${red} removing oldest snapshot... ${nc}\n"
	btrfs subvolume delete $ors
else
	printf "${yellow} too few snapshots, not deleting anything ${nc}\n"
fi

cd / && umount /mnt
