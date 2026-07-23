#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

: "${TG_BOT_CHAT_ID:?Please, define TG_BOT_CHAT_ID and TG_BOT_API_TOKEN first! To get TG_BOT_CHAT_ID, run the following command and look for the \"chat\":{\"id\":xxxxxxx string: curl -s https://api.telegram.org/bot$TG_BOT_API_TOKEN/getUpdates}"

proxy_args=()
proxy_port=$(cat /usr/l{ib,ocal}/x-ui/bin/config.json 2>/dev/null |
             grep -B 12 -A 12 '"tag"[[:space:]]*:[[:space:]]*"panel-egress"' |
             grep -o '"port"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*' | head -n 1)
[[ -n "$proxy_port" ]] && proxy_args=(-x "socks5h://127.0.0.1:$proxy_port")

msg="${1:-"<b>$(date '+%d.%m.%Y')</b><pre>$(vnstat -s)</pre>"}"

for id in ${TG_BOT_CHAT_ID//,/ }; do
     /usr/bin/curl "${proxy_args[@]}" --no-progress-meter  --connect-timeout 10 \
              -F chat_id="$id" -F parse_mode="HTML" --form-string text="$msg" \
              -F link_preview_options='{"is_disabled":'"${2:-true}"'}' \
              "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendMessage" 2>&1
done
