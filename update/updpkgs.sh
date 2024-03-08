#!/bin/bash

[ -z "$PATHINSTANCE" ] && source /etc/profile.d/instance.sh
[ -z "$PATHINSTANCE" ] && { echo "Please set $PATHINSTANCE env variable!"; exit 1; }

ONLINE=0
while read -r site; do ping -w 1 -c 1 "$site" &> /dev/null && ONLINE=1 && break; sleep 15; done < <(grep -Po '(?<=Server = https:\/\/)([^\/]*)' /etc/pacman.d/mirrorlist)
[ $ONLINE -eq 0 ] && exit 0

reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist
/usr/bin/pacman -Sy
COUNTUPD=$(/usr/bin/pacman -Qu | grep -v "\[ignored\]" | /usr/bin/wc -l)
[ -x "/usr/bin/repoctl" ] && COUNTREPOUPD=$(/usr/bin/repoctl status -a | grep "upgrade" | /usr/bin/wc -l) || COUNTREPOUPD=0

if [ "$COUNTUPD" -gt 0 ] || [ "$COUNTREPOUPD" -qt 0 ]
then
[ "$COUNTUPD" -gt 0 ] && UPDATESLOCAL=$(/usr/bin/pacman -Qu)
[ "$COUNTREPOUPD" -gt 0 ] && UPDATESREPO="

<b>Repo updates:</b>
"$(/usr/bin/repoctl status -a | grep "upgrade" | tr -s " " | sed 's/^ //g;s/: upgrade(/ /g;s/)//g')

md5file=$(md5sum < /var/log/updpackages.log )
md5upd=$(echo "$UPDATESLOCAL$UPDATESREPO"| md5sum)
host=$(uname -n)

  if [ "$md5file"  != "$md5upd" ]
  then
    echo "$UPDATESLOCAL$UPDATESREPO">/var/log/updpackages.log

## TG BOT MODULE
    if [ "$COUNTUPD" -lt 16 ]
    then
    MSG="<b>Available updates:</b>
$UPDATESLOCAL$UPDATESREPO

$(( COUNTUPD + COUNTREPOUPD )) total on <b>$host</b>"
    else
    MSG="<b>Available updates:</b>
$(( COUNTUPD + COUNTREPOUPD )) total on <b>$host</b>"
    fi
    [ -f "$PATHINSTANCE"/scripts/tgsay.sh ] && "$PATHINSTANCE"/scripts/tgsay.sh "$MSG"

## Desktop notifier: KDE MODULE
    SESSION="plasma"
    PID=$(pgrep $SESSION | head -1)
    if [ -n "$PID" ]
    then
        DBUS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/"$PID"/environ | tr -d '\0')
        UPDMODE=$(grep -E "(systemd|linux|grub)" /var/log/updpackages.log > /dev/null && echo "security-low" || echo "system-software-install")
        USERKDE=$(echo "$PATHINSTANCE" | cut -d"/" -f3)
        [ -n "$DBUS" ] && [ -x "$(command -v notify-send)" ] && sudo -u "$USERKDE" DISPLAY=:0 "$DBUS" notify-send --icon="$UPDMODE" "Available updates ($COUNTUPD):" "$(cat /var/log/updpackages.log)"
    fi


## Bar notifer: waybar
    PID=$(pgrep waybar | head -1)
    if [ -n "$PID" ]
    then
        pkill -RTMIN+8 waybar
    fi
  fi
fi
