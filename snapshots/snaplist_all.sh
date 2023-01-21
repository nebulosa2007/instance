#!/bin/bash

red='\033[0;31m'
nc='\033[0m'
yellow='\033[1;33m'

#check root
if [ $(whoami) != 'root' ]; then
    printf "${red}Command must be run with sudo.${nc}\n" && exit 1
fi

#number of root snapshots
rsl="$(btrfs subvolume list / | awk '/root-snapshot/' | wc -l)"

#number of home snapshots
hsl="$(btrfs subvolume list / | awk '/home-snapshot/'| wc -l)"

#print colored output to terminal
printf ${red}"list of root snapshots:${yellow} $rsl ${nc}\n"

#list of root snapshots by name
btrfs subvolume list / | awk '/root-snapshot/ {print $1"="$2" "$NF}'

#skip a line
printf "\n"

#print colored output to terminal
printf ${red}"list of home snapshots:${yellow} $hsl ${nc}\n"

#list of home snapshots by name
btrfs subvolume list / | awk '/home-snapshot/ {print $1"="$2" "$NF}'
