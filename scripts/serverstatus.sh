#!/bin/bash

# pikaur -Syu --needed vnstat
source /etc/instance.conf

uptime
echo
who -H
echo
free -m
echo
df -h | grep -E "/[s|v]da"
echo
COUNTUPD=$(pacman -Qu | grep -v "ignored" | wc -l)
if [ $COUNTUPD -gt 0 ]
then
        echo "Available updates:"
        if [ $COUNTUPD -lt 16 ]
	then
        	cat /var/log/updpackages.log
	fi
        echo "$COUNTUPD total"
        echo
fi
echo
echo "Total packages: $(/usr/bin/pacman -Q | wc -l)"
echo
[ -f /usr/bin/vnstat                    ] && { vnstat --oneline | cut -d";" -f 8,9,10,11| sed 's/;/   RX: /;s/;/   TX: /;s/;/   Total: /'; echo; }
[ -f /usr/bin/vnstat                    ] && { echo -n "Estimated per month: "; vnstat -m 1 | grep estimated | cut -d"|" -f3 | sed 's/  //'; echo; }
[ -f $PATHINSTANCE/scripts/age.sh ] &&   source $PATHINSTANCE/scripts/age.sh
echo

