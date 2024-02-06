#!/bin/bash

source /etc/instance.conf

ONLINE=0
for testsite in $(grep "Server" /etc/pacman.d/mirrorlist | cut -d"/" -f3) ; do ping -q -w 1 -c 1 $testsite &> /dev/null && { ONLINE=1; break; } || { echo "Wait online"; sleep 15; } ; done
[ $ONLINE -eq 0 ] && exit 0

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
    echo "$UPDATES">/var/log/updpackages.log


## TG BOT MODULE
    if [ $COUNTUPD -lt 16 ]
    then
    MSG="<b>Available updates:</b>
$UPDATES

$COUNTUPD total on <b>$host</b>"
    else
    MSG="<b>Available updates:</b>
$COUNTUPD total on <b>$host</b>"
    fi
    [ -f $PATHINSTANCE/scripts/tgsay.sh ] && $PATHINSTANCE/scripts/tgsay.sh "$MSG"


## Desktop notifier: KDE MODULE
    SESSION="plasma"
    PID=$(pgrep $SESSION | head -1)
    if [ -n "$PID" ]
    then
        DBUS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ | tr -d '\0')
        UPDMODE=$(grep -E "(systemd|linux|grub)" /var/log/updpackages.log > /dev/null && echo "security-low" || echo "system-software-install")
        USERKDE=$(echo $PATHINSTANCE | cut -d"/" -f3)
        [ -n "$DBUS" ] && [ -x "$(command -v notify-send)" ] && sudo -u $USERKDE DISPLAY=:0 $DBUS notify-send --icon=$UPDMODE "Available updates ($COUNTUPD):" "$(cat /var/log/updpackages.log)"
    fi


## Bar notifer: waybar
    PID=$(pgrep waybar | head -1)
    if [ -n "$PID" ]
    then
        pkill -RTMIN+8 waybar
    fi
  fi
fi
