#!/bin/bash
#shellcheck disable=1091

[ -z "$PATHINSTANCE" ] && source /etc/profile.d/instance.sh
[ -z "$PATHINSTANCE" ] && { echo "Please set \$PATHINSTANCE env variable!"; exit 1; }

ONLINE=0
while read -r site; do ping -w 1 -c 1 "$site" &> /dev/null && ONLINE=1 && break; sleep 15; done < <(grep -Po '(?<=Server = https:\/\/)([^\/]*)' /etc/pacman.d/mirrorlist)
[ $ONLINE -eq 0 ] && exit 0

reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist
/usr/bin/pacman -Sy
COUNTUPD=$(/usr/bin/pacman -Qu | grep -v "\[ignored\]" | /usr/bin/wc -l)
if [ -x "/usr/bin/repoctl" ]
then
    REPOUPD=$(/usr/bin/repoctl status -a | grep "upgrade")
    COUNTREPOUPD=$(echo "$REPOUPD" | /usr/bin/wc -l)
else
    COUNTREPOUPD=0
fi

if [ "$COUNTUPD" -gt 0 ] || [ "$COUNTREPOUPD" -gt 0 ]
then
[ "$COUNTUPD" -gt 0 ] && UPDATESLOCAL="<b>Available updates:</b>
$(/usr/bin/pacman -Qu | grep -v '\[ignored\]')"
[ "$COUNTREPOUPD" -gt 0 ] && UPDATESREPO="
<b>Repo updates:</b>
$(echo "$REPOUPD" | tr -s ' ' | sed 's/^ //g;s/: upgrade(/ /g;s/)//g')"

[ ! -f /var/log/updpackages.log ] && touch /var/log/updpackages.log
md5file=$(md5sum < /var/log/updpackages.log )
md5upd=$(echo -e "$UPDATESLOCAL\n$UPDATESREPO"| md5sum)
host=$(uname -n)

  if [ "$md5file"  != "$md5upd" ]
  then
    echo "$UPDATESLOCAL
$UPDATESREPO" > /var/log/updpackages.log


## Telegram notifier: BOT MODULE
    if [ "$(( COUNTUPD + COUNTREPOUPD ))" -lt 16 ]
    then
    MSG="$UPDATESLOCAL
$UPDATESREPO

$(( COUNTUPD + COUNTREPOUPD )) total on <b>$host</b>"
    else
    MSG="Available updates: $COUNTUPD
Repo updates: $COUNTREPOUPD

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


## Bar notifer: WAYBAR MODULE
    if [ -n "$(pgrep waybar | head -1)" ]
    then
        pkill -RTMIN+8 waybar
    fi
  fi
fi
