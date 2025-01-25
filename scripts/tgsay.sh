#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

if [ -z "$TG_BOT_CHAT_ID" ]; then
    echo "Please, define TG_BOT_CHAT_ID and TG_BOT_API_TOKEN first! See \"chat\":{\"id\":xxxxxxx string below from request: curl https://api.telegram.org/bot$TG_BOT_API_TOKEN/getUpdates"
    exit 1
fi

MSG=$(echo "$@" | tr '\n' '[' | sed 's/ /%20/g;s/\[/%0A/g;s/\]/%5D/g;s/+/%2B/g') #Urlencoding some symbols for curl

#/usr/bin/wget -qO- "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendMessage?chat_id=$TG_BOT_CHAT_ID&parse_mode=html&text=$@" 2>&1
/usr/bin/curl --no-progress-meter "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendMessage?chat_id=$TG_BOT_CHAT_ID&parse_mode=HTML&text=$MSG" 2>&1
