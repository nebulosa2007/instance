#!/bin/bash
#Number of snapshots allowed
sn=5
ROOTVOLUME="@root"

ACTION=$(grep "\[PACMAN\]" /var/log/pacman.log | tail -1 | cut -d" " -f3-)
#Declare colors
red='\033[0;31m'
nc='\033[0m'
yellow='\033[1;33m'

#check for Root
if [ $(whoami) != 'root' ]; then
    printf "${red} Command must be run as root...exiting${nc}\n" && exit 1
fi

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
    printf "${yellow} mounted $rsvdv to /mnt${nc}\n"
else
    printf "${red} no btrfs drives found${nc}\n" && exit 1
fi

#MUST be in this directory to perform task
cd /mnt

# Check that root subvolume is found...
if [ -e "$rsv" ]; then
    printf "${yellow} root subvolume found... $rsv${nc}\n"
else
    printf "${red} no root subvolume found... exiting${nc}\n" && cd $HOME && umount /mnt && exit 1
fi

# Create snapshot of root subvolume and place in snapshot subvolume with date attached...
echo "["root-snapshot-$cdt"]" $ACTION
btrfs subvolume snapshot $rsv root-snapshot-$cdt

#remove a snapshot if there are more than 5
if [ "$rsl" -ge "$sn"  ]; then
	printf "${red} removing oldest snapshot... ${nc}\n"
	btrfs subvolume delete $ors
else
	printf "${yellow} too few snapshots... ${nc}\n"
	printf "${yellow} not deleting anything ${nc}\n"
fi

cd $HOME && umount /mnt
