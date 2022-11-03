#!/bin/bash

METHOD=$(/usr/bin/ls -ctl --time-style +"%Y-%m-%d" /etc | tail -1 | sed 's/ /\n/g'| tail -2 | head -1)
#METHOD=$(head -1 /var/log/pacman.log | cut -c 2-11)

DAYSBETWEEN=$(( ($(date -d $(date +%Y-%m-%d) +%s) - $(date -d $METHOD +%s)) / 86400 ))

YEARSCALC=$(( $DAYSBETWEEN / 365 ))
MONTHSCALC=$(( ($DAYSBETWEEN - ($YEARSCALC * 365)) / 30 ))
DAYSCALC=$(( $DAYSBETWEEN -($YEARSCALC * 365) - ($MONTHSCALC * 30) ))

[[ $YEARSCALC > 0  ]] && YEARS=$YEARSCALC"y "
[[ $MONTHSCALC > 0 ]] && MONTHS=$MONTHSCALC"m "
[[ $DAYSCALC > 0   ]] && DAYS=$DAYSCALC"d"

echo "System age: "$YEARS$MONTHS$DAYS" (since $METHOD)"
