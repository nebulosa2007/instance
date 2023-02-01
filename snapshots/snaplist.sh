#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nc='\033[0m'

#/ snapshots
printf "List of root snapshots:${green} $(sudo btrfs subvolume list / | awk '/root-snapshot/' | wc -l) ${nc}\n\n"

sudo btrfs subvolume list / | awk '/root-snapshot/ {print $NF}'| while read snapshot
do
    cat /var/log/pacman.log | while read pacman_log_line
    do
        if [[ $pacman_log_line == *"[$snapshot]"* ]];
        then
            filtered_pacman_log_line=$(echo $pacman_log_line | cut -d" " -f4- | sed "s/Running //;s/--color=always //;s/--needed //;s/'//g;s/pacman //;")
            operation=$(echo $filtered_pacman_log_line | cut -d" " -f1)
            pacman_log_line=$(echo $filtered_pacman_log_line | cut -d" " -f2-| sed 's/full system upgrade//')
            echo -n $snapshot": "
			[ $operation == "-S" ] && echo -ne ${green}"Before installing  "
            [ $operation == "--upgrade" ] && echo -ne ${green}"Before installing  "
            [ $operation == "--sync" ] && echo -ne ${green}"Before installing  "
            [ $operation == "-Rsc" ] && echo -ne ${red}"Before deleting    "
            [ $operation == "-Rsnc" ] && echo -ne ${red}"Before deleting    "
            [ $operation == "-Rsn" ] && echo -ne ${red}"Before deleting    "
            [ $operation == "--remove" ] && echo -ne ${red}"Before deleting    "
            [ $operation == "starting" ] && echo -ne ${yellow}"Before upgrading   "
            [ $operation == "-U" ] && echo -ne ${yellow}"Before upgrading   "
            updated=$(awk '/'$snapshot'/,/transaction completed$/' /var/log/pacman.log | grep -E "\[ALPM\] upgraded" | cut -d" " -f4,7 | sed 's/)/,/')
            [ "$updated" == "" ] && updated=$(awk '/'$snapshot'/,/transaction completed$/' /var/log/pacman.log | grep -E "\[ALPM\] (removed|installed|downgraded)" | cut -d" " -f4,5,7 | sed 's/)/,/;s/(//') && pacman_log_line=" "
            updated=$(echo $updated | sed 's/,$/ /;s/(/ /')
            echo -e $pacman_log_line$updated${nc}
        fi
    done
done

#/home snapshots
printf "\n"
printf "List of home snapshots:${green} $(sudo btrfs subvolume list / | awk '/home-snapshot/'| wc -l) ${nc}\n\n"
sudo btrfs subvolume list / | awk '/home-snapshot/ {print $1"="$2" "$NF}'
