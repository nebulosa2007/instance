#!/bin/bash

SNAPDIR="/.snapshots"

#Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

function print_snapshot_comment
{
  hookfile="yabsnap-pacman-pre.hook"
  pacman_timestamp="${1:6:4}-${1:10:2}-${1:12:2}T${1:14:2}:${1:16:1}" 

  pacman_log_line=$(grep -E -B1 "$pacman_timestamp.*$hookfile" /var/log/pacman.log | head -1 )
  operation=$(echo $pacman_log_line | cut -d" " -f3- | \
  sed "s/Running //;\
       s/--color=always //;\
       s/--needed //;s/'//g;\
       s/\/usr\/bin\///;\
       s/pacman //" | \
  cut -d" " -f1)
  case $operation in
    "-S"  | "--sync"   ) color=$green;  action="Installing";;
    "-R"* | "--remove" ) color=$red;    action="Deleting";;
    "-U"  | "starting" ) color=$yellow; action="Upgrading";;
    "--upgrade") [[ $packages == *"->"* ]] && { color=$yellow; action="Upgrading";} || { color=$green; action="Installing";};;
  esac

  packages=$(echo $(awk '/'$pacman_timestamp'.*started/, /'$pacman_timestamp'.*completed/' /var/log/pacman.log | \
    grep -E "\[ALPM\] (removed|installed|downgraded|upgraded|reinstalled)" | \
    cut -d" " -f4-7 | sed 's/)/,/;s/(//') | sed 's/,$/ /')
  echo -e ${color}$action" "$packages${nc}
}


if [ -z $1 ]
then
    list=$(ls -d -1 $SNAPDIR/*/ 2>/dev/null | tr " " "\n" | sed 's/\/$//g')
    printf "List of snapshots:${green} $(echo $list | wc -w) ${nc}\n\n"
else
    list=$SNAPDIR/$1
    LOG=$(print_snapshot_comment $1)
fi
echo $list | tr " " "\n" | while read snapshot
do
   echo -n $(basename $snapshot)": "
   cat $snapshot-meta.json | echo $(tr -d '"{}')
   echo
   echo $LOG
done
