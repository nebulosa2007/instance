#!/bin/env bash

SNAPDIR="/.snapshots"
PREFIX="@root"

[ ! -x "$(command -v yabsnap)" ] && { echo "This script works with Yabsnap snapshots only!"; exit 1; }
[ ! -d $SNAPDIR ] && { echo "Snaphots directory not found: $SNAPDIR"; exit 1; }

#Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

function print_snapshot_comment
{

  hookfile="yabsnap-pacman-pre.hook"

  # Transform yabsnap timestamp into pacman log timestamp without
  # two last digits: 20230101093014 -> 2023-01-01T09:30
  pacman_timestamp="${1:0:4}-${1:4:2}-${1:6:2}T${1:8:2}:${1:10:2}"

  # Recognizing operation in pacman log:
  pacman_log_line=$(grep -E -B1 "$pacman_timestamp.*$hookfile" /var/log/pacman.log | head -1 )
  operation=$(echo "$pacman_log_line" | cut -d" " -f3- | \
  sed "s/Running //;\
       s/--color=always //;\
       s/--needed //;s/'//g;\
       s/\/usr\/bin\///;\
       s/pacman //" | \
  cut -d" " -f1)

  # Select color of comment and action
  case $operation in
    "-S"  | "--sync"   ) color=$green;  action="Installing";;
    "-R"* | "--remove" ) color=$red;    action="Deleting";;
    "-U"  | "starting" ) color=$yellow; action="Upgrading";;
    "--upgrade") if [[ $packages == *"->"* ]]; then color=$yellow; action="Upgrading"; else color=$green; action="Installing"; fi;;
  esac

  # Select strings between "[ALPM] transaction started ... [ALPM] transaction completed" with the timestamp and grep info about
  # all packages that we found, comma separated
  # TODO: Not always works well because of fixed timestamp and sometimes awk select strings not closest to each other
  packages=$(echo $(awk '/'$pacman_timestamp'.*started/, /'$pacman_timestamp'.*completed/' /var/log/pacman.log | \
    grep -E "\[ALPM\] (removed|installed|downgraded|upgraded|reinstalled)" | \
    cut -d" " -f4-7 | sed 's/)/,/;s/(//') | sed 's/,$/ /')

  # Print comment for snapshot
  echo -e "\n""${color}""$action"" ""$packages""${nc}""\n\n"
}


if [ -z "$1" ]
then
    # List all snapshots
    list=$(/usr/bin/ls -d -1 $SNAPDIR/$PREFIX-*/ 2>/dev/null | tr " " "\n" | sed 's/\/$//g')
    printf "List of snapshots: ${green}%s${nc}\n\n" "$(echo "$list" | wc -w)"
else
    # If script is using with fzf and $1 is yabsnap timestamp,e.g.: 20230101093014
    list=$SNAPDIR/$PREFIX-$1
fi

# Print comments for snapshosts
echo "$list" | tr " " "\n" | while read -r snapshot
do
   # Print a time of shapshot
   #echo $(basename $snapshot)": "
   t=${snapshot##*-}
   echo -n "${t:0:4}-${t:4:2}-${t:6:2} ${t:8:2}:${t:10:2}:${t:12:2}    "
   # Print info about snapshot in one line from json file
   cat "$snapshot-meta"".json" | tr -d '"{}'
   # If the trigger is "I" print log from /var/log/pacman.log
   [ "$(grep -Po '(?<= \"trigger\": \")(\S)' "$snapshot-meta".json)" == "I" ] && print_snapshot_comment "${snapshot:18:15}"
done
