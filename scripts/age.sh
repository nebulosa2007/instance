#!/bin/env bash

DATE=$(/usr/bin/ls -ctl --time-style +"%Y-%m-%d" /etc | tail -1 | grep -Po "[0-9]+-[0-9]+-[0-9]+")
#or
#DATE=$(stat /etc | tail -1 | cut -d" " -f3)
#or
#DATE=$(head -1 /var/log/pacman.log | cut -c 2-11)

LOCALE=$(date -d "$DATE" +"%d.%m.%Y")
DAYSBETWEEN=$(( ($(date +%s) - $(date -d "$DATE" +%s)) / 86400 ))

YEARSCALC=$((DAYSBETWEEN / 365))
MONTHSCALC=$(((DAYSBETWEEN - (YEARSCALC * 365)) / 30))
DAYSCALC=$((DAYSBETWEEN - (YEARSCALC * 365) - (MONTHSCALC * 30)))

YEARS=$([[ "$YEARSCALC" -gt 0 ]] && echo "${YEARSCALC}y ")
MONTHS=$([[ "$MONTHSCALC" -gt 0 ]] && echo "${MONTHSCALC}m ")
DAYS=$([[ "$DAYSCALC" -gt 0 ]] && echo "${DAYSCALC}d")

echo "System age: $YEARS$MONTHS$DAYS (since $LOCALE)"
