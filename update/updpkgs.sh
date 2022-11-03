#!/bin/bash

reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist
/usr/bin/pacman -Sy
COUNTUPD=$(/usr/bin/pacman -Qu | /usr/bin/wc -l)

if [ $COUNTUPD -gt 0 ]
then
UPDATES=$(/usr/bin/pacman -Qu)
md5file=$(cat /var/log/updpackages.log | md5sum)
md5upd=$(echo "$UPDATES"| md5sum)
host=$(uname -n)

if [ "$md5file"  != "$md5upd" ]
then
    if [ $COUNTUPD -lt 16 ]
    then
	[ -f /home/ds/instance/scripts/tgsay.sh ] && /home/ds/instance/scripts/tgsay.sh "<b>Available updates:</b>
$UPDATES

$COUNTUPD total on <b>$host</b>"
    else
	[ -f /home/ds/instance/scripts/tgsay.sh ] && /home/ds/instance/scripts/tgsay.sh "<b>Available updates:</b>
$COUNTUPD total on <b>$host</b>"
    fi
echo "$UPDATES">/var/log/updpackages.log
fi

fi
