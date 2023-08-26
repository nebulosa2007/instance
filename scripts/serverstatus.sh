#!/bin/bash

# pikaur -Syu --needed vnstat netcat lv_sensors
source /etc/instance.conf

LIMIT="1TB"

if [ "$1" == "estimated" ]
then
        [ -f /usr/bin/vnstat             ] && { echo -n "Expected month traffic: "; vnstat -m 1 | grep estimated | cut -d"|" -f3 | sed 's/  //;s/\n\r//'; echo "Limit is: "$LIMIT; }
else
        uptime
        if [ `who | wc -l` -gt 0 ]
        then
                echo
                echo Logins:
                who -H
        fi
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
        [ -f /usr/bin/vnstat                       ] && { vnstat --oneline | cut -d";" -f 8,9,10,11| sed 's/;/   RX: /;s/;/   TX: /;s/;/   Total: /'; }
        [ -f /usr/bin/vnstat                       ] && { echo -n "Expected month traffic: "; vnstat -m 1 | grep estimated | cut -d"|" -f3 | sed 's/  //'; echo; }
        [ -f /usr/bin/nc                           ] && { nc localhost 7634 |sed 's/|//m' | sed 's/||/ \n/g' | awk -F'|' '{print $1 " " $3 " " $4}'; }
        [ -f /usr/bin/sensors                      ] && { sensors | egrep '(temp1|fan1)' | awk '{print $1 " " $2}'; }
        [ -f /usr/bin/nvidia-smi                   ] && { nvidia-smi -q -d temperature | grep Current | awk '{print $1 " " $5 " " $6}'; }
        [ -f $PATHINSTANCE/scripts/age.sh          ] && source $PATHINSTANCE/scripts/age.sh
        echo
fi
