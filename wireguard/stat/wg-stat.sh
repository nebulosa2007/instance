#!/bin/bash

LOGDIR="/var/log/wgstat"
CLIENTS=$(awk '/###/,/AllowedIPs =/' /etc/wireguard/wg0.conf | grep -E "(###|AllowedIPs)" | sed 's/### Client //;s/AllowedIPs = //' | tr '\n' '|' | sed 's/|10/ 10/g')
DATE=$(date +"%F")
HOUR=$(date +"%H")
UPTIME=$(awk -F'.' '{print $1}' /proc/uptime)

mkdir -p $LOGDIR
LOGFILE="$LOGDIR/$DATE-$HOUR.log"
echo -n > $LOGFILE

wg show all dump | awk 'FNR>1 {print $5,$7,$8}' | sort -V | while read stat_line
do
    name_client=$(echo $CLIENTS | tr '|' '\n' | grep "$(echo $stat_line | cut -d" " -f1)" | cut -d" " -f1)
    echo $DATE" "$HOUR" "$UPTIME" "$name_client" "$stat_line >> $LOGFILE  
done
