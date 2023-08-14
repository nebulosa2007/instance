#!/bin/bash

source /etc/instance.conf

reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist
/usr/bin/pacman -Sy
COUNTUPD=$(/usr/bin/pacman -Qu | grep -v "\[ignored\]" | /usr/bin/wc -l)

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
	[ -f $PATHINSTANCE/scripts/tgsay.sh ] && $PATHINSTANCE/scripts/tgsay.sh "<b>Available updates:</b>
$UPDATES

$COUNTUPD total on <b>$host</b>"
    else
	[ -f $PATHINSTANCE/scripts/tgsay.sh ] && $PATHINSTANCE/scripts/tgsay.sh "<b>Available updates:</b>
$COUNTUPD total on <b>$host</b>"
    fi
echo "$UPDATES">/var/log/updpackages.log
fi

#Desktop notifier: KDE
if [ "$md5file"  != "$md5upd" ]
then
	SESSION="plasma"
	PID=$(pgrep $SESSION | head -1)
	if [ -n "$PID" ]
	then
		DBUS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ | tr -d '\0')
		UPDMODE=$(grep -E "(systemd|linux)" /var/log/updpackages.log > /dev/null && echo "security-low" || echo "system-software-install")
		USERKDE=$(echo $PATHINSTANCE | cut -d"/" -f3)
		[ -n "$DBUS" ] && [ -f /usr/bin/notify-send ] && sudo -u $USERKDE DISPLAY=:0 $DBUS notify-send --icon=$UPDMODE "Available updates ($COUNTUPD):" "$(cat /var/log/updpackages.log)"
	fi
fi
fi
