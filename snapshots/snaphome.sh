#!/bin/bash
#number of snapshots allowed
sn=5
HOMEVOLUME="@home"

#Declare colors
red='\033[0;31m'
nc='\033[0m'
yellow='\033[1;33m'

#check for Root
if [ $(whoami) != 'root' ]; then
    printf "${red} Command must be run as root...exiting${nc}\n" && exit 1
fi

#home subvolume device
hsvdv="$(df -Th | awk '/btrfs/ && /home/' | cut -d' ' -f 1)"

#current date
cdt=`date +"%Y-%b-%d-%T"`

#home subvolume
hsv="$(btrfs subvolume list / | awk '/level 5/ && /home/ {print $NF}')"

#number of home snapshots
hsl="$(btrfs subvolume list / | awk '/home-snapshot/' | wc -l)"

#oldest home snapshot
ohs="$(btrfs subvolume list / | awk '/home-snapshot/ {print $NF}' | head -n1)"


#Mount home subvolume to /mnt
if [ -e "$hsvdv" ]; then
    mount $hsvdv /mnt
    printf "${yellow} mounted $hsvdv to /mnt${nc}\n"
else
    printf "${red} no btrfs drives found${nc}\n" && exit 1
fi

#MUST be in /mnt to perform task
cd /mnt

# Check home subvolume is found...
if [ -e "$hsv" ]; then
    printf "${yellow} found home subvolume...$hsv${nc}\n"
else
    printf "${red} no home subvolume found... exiting${nc}\n" && cd $HOME && umount /mnt && exit 1
fi

#Make snapshot and place in snapshot directory
btrfs subvolume snapshot $hsv $ssv/home-snapshot-$cdt

#remove a home snapshot if there are more than 5
if [ "$hsl" -ge "$sn" ]; then
    printf "${red} removing oldest snapshot... ${nc}\n"
    btrfs subvolume delete $ohs
else
    printf "${yellow} too few snapshots...\n"
    printf "not deleting anything ${nc}\n"
fi

cd $HOME && umount /mnt
