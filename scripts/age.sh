#!/bin/bash

#METHOD=$(stat /etc | tail -1 | cut -d" " -f3)
METHOD=$(/usr/bin/ls -ctl --time-style +"%Y-%m-%d" /etc | tail -1 | grep -Po "[0-9]+-[0-9]+-[0-9]+")
#METHOD=$(head -1 /var/log/pacman.log | cut -c 2-11)

DATE_LOCAL=$(echo $METHOD | sed 's/-/ /g' | awk '{print $3"."$2"."$1}')
DAYSBETWEEN=$(( ($(date -d $(date +%Y-%m-%d) +%s) - $(date -d $METHOD +%s)) / 86400 ))

YEARSCALC=$(( $DAYSBETWEEN / 365 ))
MONTHSCALC=$(( ($DAYSBETWEEN - ($YEARSCALC * 365)) / 30 ))
DAYSCALC=$(( $DAYSBETWEEN -($YEARSCALC * 365) - ($MONTHSCALC * 30) ))

[[ $YEARSCALC > 0  ]] && YEARS=$YEARSCALC"y "
[[ $MONTHSCALC > 0 ]] && MONTHS=$MONTHSCALC"m "
[[ $DAYSCALC > 0   ]] && DAYS=$DAYSCALC"d"

echo "System age: "$YEARS$MONTHS$DAYS" (since $DATE_LOCAL)"
