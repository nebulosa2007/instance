#!/bin/bash

# pikaur -Syu --needed vnstat netcat lv_sensors
[ -z "$PATHINSTANCE" ] && { echo "Please set $PATHINSTANCE env variable!"; exit 1; }

if [ "$1" == "estimated" ]
then
        [ -x "$(command -v vnstat)"       ] && { echo -n "Expected month traffic: "; vnstat -m 1 | grep estimated | cut -d"|" -f3 | sed 's/  //;s/\n\r//'; echo "Limit is: ""$LIMIT"; }
else
        uptime
        if [ "$(who | wc -l)" -gt 0 ]
        then
                echo
                echo Logins:
                who -H
        fi
        echo
        free -m
        echo
        df -h | grep -E "$( [ "$(mount | grep -Po '(?<= on \/ type )(\S+)')" == "btrfs" ] && echo '/$' || echo '/[s|v]da' )"
        echo
        COUNTUPD=$(pacman -Qu | grep -cv "ignored")
        if [ "$COUNTUPD" -gt 0 ]
        then
                echo "Available updates:"
                if [ "$COUNTUPD" -lt 16 ]
	            then
                     cat /var/log/updpackages.log
	            fi
                echo "$COUNTUPD total"
                echo
        fi
        echo
        echo "Total packages: $(/usr/bin/pacman -Q | wc -l)"
        echo
        [ -x "$(command -v vnstat)"         ] && { vnstat --oneline | cut -d";" -f 8,9,10,11| sed 's/;/   RX: /;s/;/   TX: /;s/;/   Total: /'; echo -n "Expected month traffic: "; vnstat -m 1 | grep estimated | cut -d"|" -f3 | sed 's/  //'; echo; }
        [ -x "$(command -v nc)"             ] && { nc localhost 7634 |sed 's/|//m' | sed 's/||/ \n/g' | awk -F'|' '{print $1 " " $3 " " $4}'; }
        [ -x "$(command -v sensors)"        ] && { sensors | grep -E '(temp1|fan1)' | awk '{print $1 " " $2}'; }
        [ -x "$(command -v nvidia-smi)"     ] && { nvidia-smi -q -d temperature | grep Current | awk '{print $1 " " $5 " " $6}'; }
        [ -f "$PATHINSTANCE"/scripts/age.sh ] && source "$PATHINSTANCE"/scripts/age.sh
        echo
fi
