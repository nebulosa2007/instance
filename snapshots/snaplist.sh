#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

function print_snapshot_log
{
	hookfile="01-yabsnap-pacman-pre.hook"
    cat /var/log/pacman.log | grep "running '"$hookfile"'" | while read pacman_log_line
    do
        
        if [[ $pacman_log_line == *"[$snapshot]"* ]];
        then
            operation=$(echo $pacman_log_line | cut -d" " -f4- | \
            sed "s/Running //;\
                 s/--color=always //;\
                 s/--needed //;s/'//g;\
                 s/\/usr\/bin\///;\
                 s/pacman //" | \
            cut -d" " -f1)
            packages=$(echo $(awk '/'$snapshot'/,/transaction completed$/' /var/log/pacman.log | \
                       grep -E "\[ALPM\] (removed|installed|downgraded|upgraded|reinstalled)" | \
                       cut -d" " -f4-7 | sed 's/)/,/;s/(//') | sed 's/,$/ /')
            case $operation in
            "-S"  | "--sync"   ) color=$green;  action="install";;
            "-R"* | "--remove" ) color=$red;    action="delet";;
            "-U"  | "starting" ) color=$yellow; action="upgrad";;
                    "--upgrade") [[ $packages == *"->"* ]] && { color=$yellow; action="upgrad";} || { color=$green; action="install";};;
            esac

            echo -e $snapshot": "${color}"Before "$action"ing "$packages${nc}
        fi
    done
}

if [ -z $1 ]
then
    SNAPDIR="/.snapshots"
    LISTROOT=$(ls -d -1 $SNAPDIR/*/ 2>/dev/null | tr " " "\n" | sed 's/\/$//g')
    printf "List of snapshots:${green} $(echo $LISTROOT | wc -w) ${nc}\n\n"
    echo $LISTROOT | tr " " "\n" | while read snapshot
    do
        echo -n $(basename $snapshot)": "
        cat $snapshot-meta.json | echo $(tr -d '"{}')
    done
else
    #snapshot=$1
    cat $1-meta.json | echo $(tr -d '"{}')
    #LOG=$(print_snapshot_log $snapshot)
    #[ "$LOG" == "" ] && echo "No comments about this shapshot found" || echo $LOG
fi
