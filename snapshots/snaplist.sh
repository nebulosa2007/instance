#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
nc='\033[0m'

function print_snapshot_log
{
    cat /var/log/pacman.log | while read pacman_log_line
    do
        if [[ $pacman_log_line == *"[$snapshot]"* ]];
        then
            filtered_pacman_log_line=$(echo $pacman_log_line | cut -d" " -f4- | sed "s/Running //;s/--color=always //;s/--needed //;s/'//g;s/pacman //;")
            operation=$(echo $filtered_pacman_log_line | cut -d" " -f1)
            packages=$(awk '/'$snapshot'/,/transaction completed$/' /var/log/pacman.log | grep -E "\[ALPM\] (removed|installed|downgraded|upgraded)" | cut -d" " -f4-7 | sed 's/)/,/;s/(//')
            packages=$(echo $packages | sed 's/,$/ /')
            echo -n $snapshot": "
            [ $operation == "-S" ] && echo -ne ${green}"Before installing "
            [ $operation == "--sync" ] && echo -ne ${green}"Before installing "
            [ $operation == "-Rsc" ] && echo -ne ${red}"Before deleting   "
            [ $operation == "-Rsnc" ] && echo -ne ${red}"Before deleting   "
            [ $operation == "-Rsn" ] && echo -ne ${red}"Before deleting   "
            [ $operation == "--remove" ] && echo -ne ${red}"Before deleting   "
            [ $operation == "starting" ] && echo -ne ${yellow}"Before upgrading  "
            [ $operation == "-U" ] && echo -ne ${yellow}"Before upgrading  "
            [ $operation == "--upgrade" ] && { [[ $packages == *"->"* ]] && echo -ne ${yellow}"Before upgrading  " || echo -ne ${green}"Before installing "; }
            echo -e $packages${nc}
        fi
    done
}

if [ -z $1 ]
then
    #/ snapshots
    printf "List of root snapshots:${green} $(sudo btrfs subvolume list / | awk '/root-snapshot/' | wc -l) ${nc}\n\n"
    sudo btrfs subvolume list / | awk '/root-snapshot/ {print $NF}'| while read snapshot
    do
        print_snapshot_log $snapshot
    done
    printf "\n"
    #/home snapshots
    printf "List of home snapshots:${green} $(sudo btrfs subvolume list / | awk '/home-snapshot/'| wc -l) ${nc}\n\n"
    sudo btrfs subvolume list / | awk '/home-snapshot/ {print $1"="$2" "$NF}'
else
    snapshot=$1
    LOG=$(print_snapshot_log $snapshot)
    [ "$LOG" == "" ] && echo "No comments about this shapshot found" || echo $LOG
fi
