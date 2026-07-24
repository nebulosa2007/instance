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
    COUNTUPD=0
    command -v pacman >/dev/null && COUNTUPD=$(pacman -Qu | grep -cv "ignored")
    command -v apt >/dev/null && COUNTUPD=$(apt list --upgradable 2>/dev/null | grep -cv "^Listing")
    if [ "$COUNTUPD" -gt 0 ]; then
        echo "Available updates:"
        command -v pacman >/dev/null && [ "$COUNTUPD" -lt 16 ] && grep -v "<b>" /var/log/updpackages.log
        command -v apt >/dev/null && [ "$COUNTUPD" -lt 16 ] && apt list --upgradable 2>/dev/null | grep -v "^Listing"
        echo "$COUNTUPD total"
        echo
    fi
    command -v pacman >/dev/null && echo "Total packages: $(pacman -Q | wc -l)"
    command -v apt >/dev/null && echo "Total packages: $(dpkg -l | grep -c '^ii')"
    echo
    command -v vnstat &>/dev/null && vnstat --oneline | sed 's/^\([^;]*;\)\{7\}//;s/;/   RX: /;s/;/   TX: /;s/;/   Total: /;s/;.*//'
    show_estimated_traffic
    echo
    [ -f "$PATHINSTANCE"/scripts/age.sh ] && "$PATHINSTANCE"/scripts/age.sh
fi
