#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

while read -r site; do
    ping -w 1 -c 1 "$site" &>/dev/null && ONLINE=1 && break
    sleep 15
done < <(grep -Po '(?<=Server = https:\/\/)([^\/]*)' /etc/pacman.d/mirrorlist)
: "${ONLINE:?failed. Exiting...}"

reflector -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist
/usr/bin/pacman -Sy
COUNTUPD=$(/usr/bin/pacman -Qu | grep -v "\[ignored\]" | /usr/bin/wc -l)
COUNTREPOUPD=$([ -x "/usr/bin/repoctl" ] && /usr/bin/repoctl status -a | grep "upgrade" | /usr/bin/wc -l || echo "0")
if [ "$COUNTUPD" -gt 0 ] || [ "$COUNTREPOUPD" -gt 0 ]; then
    [ "$COUNTUPD" -gt 0 ] && UPDATESLOCAL="<b>Available updates:</b>
$(/usr/bin/pacman -Qu | grep -v '\[ignored\]')"
    [ "$COUNTREPOUPD" -gt 0 ] && UPDATESREPO="
<b>Repo updates:</b>
$(/usr/bin/repoctl status -a | sed -n 's/^[[:space:]]*\([^:]*\): upgrade(\([^ ]*\) -> \([^)]*\)).*/\1 \2 -> \3/p')"

    : "${LOG:=/var/log/updpackages.log}"
    touch "$LOG"
    if [ "$(md5sum <"$LOG")" != "$(echo -e "$UPDATESLOCAL\n$UPDATESREPO" | md5sum)" ]; then
        echo "$UPDATESLOCAL
$UPDATESREPO" >"$LOG"

        ## Telegram notifier: BOT MODULE
        total=$((COUNTUPD + COUNTREPOUPD))
        if [ "$total" -lt 16 ]; then
            MSG="$UPDATESLOCAL
$UPDATESREPO"
        else
            MSG="Available updates: $COUNTUPD"
            [ "$COUNTREPOUPD" -gt 0 ] && MSG=$MSG"
Repo updates: $COUNTREPOUPD"
        fi
        MSG=$MSG"

$total total on <b>$(uname -n)</b>"
        [ -f "$PATHINSTANCE"/scripts/tgsay.sh ] && "$PATHINSTANCE"/scripts/tgsay.sh "$MSG"

        ## Desktop notifier: KDE MODULE
        SESSION="plasma"
        PID=$(pgrep $SESSION | head -1)
        if [ -n "$PID" ]; then
            DBUS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/"$PID"/environ | tr -d '\0')
            UPDMODE=$(grep -E "(systemd|linux|grub)" "$LOG" >/dev/null && echo "security-low" || echo "system-software-install")
            USERKDE=$(echo "$PATHINSTANCE" | cut -d"/" -f3)
            [ -n "$DBUS" ] && [ -x "$(command -v notify-send)" ] && sudo -u "$USERKDE" DISPLAY=:0 "$DBUS" notify-send --icon="$UPDMODE" "Available updates ($COUNTUPD):" "$(<"$LOG")"
        fi

        ## Bar notifer: WAYBAR MODULE
        pgrep waybar &>/dev/null && pkill -RTMIN+9 waybar || :
    fi
fi
