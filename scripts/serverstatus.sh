#!/bin/env bash

# sudo pacman -Syu --needed vnstat
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

show_estimated_traffic() {
    if command -v vnstat &>/dev/null; then
        echo -n "Expected month traffic: "
        vnstat -m 1 | sed -n '/estimated/ s/.*| *\(.*\)|.*/\1/p'
        echo "Limit is: ${LIMIT:-"not set"}"
    fi
}

if [ "$1" == "estimated" ]; then
    show_estimated_traffic
else
    uptime
    echo
    [ "$(who | wc -l)" -gt 0 ] && echo "Logins: $(who -H)"
    echo
    free -m
    echo
    df -h | grep -E "$(mount | grep -q ' on / type btrfs' && echo '/$' || echo '/[s|v]da')"
    echo
    COUNTUPD=$(pacman -Qu | grep -cv "ignored")
    if [ "$COUNTUPD" -gt 0 ]; then
        echo "Available updates:"
        [ "$COUNTUPD" -lt 16 ] && grep -v "<b>" /var/log/updpackages.log
        echo "$COUNTUPD total"
        echo
    fi
    echo "Total packages: $(pacman -Q | wc -l)"
    echo
    command -v vnstat &>/dev/null && vnstat --oneline | sed 's/^\([^;]*;\)\{7\}//;s/;/   RX: /;s/;/   TX: /;s/;/   Total: /;s/;.*//'
    show_estimated_traffic
    echo
    [ -f "$PATHINSTANCE"/scripts/age.sh ] && "$PATHINSTANCE"/scripts/age.sh
fi
