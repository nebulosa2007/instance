#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

: "${TG_BOT_CHAT_ID:?Please, define TG_BOT_CHAT_ID and TG_BOT_API_TOKEN first! To get TG_BOT_CHAT_ID, run the following command and look for the \"chat\":{\"id\":xxxxxxx string: curl -s https://api.telegram.org/bot$TG_BOT_API_TOKEN/getUpdates}"

MSG=$(echo "$1" | tr '\n' '[' | sed 's/ /%20/g;s/\[/%0A/g;s/\]/%5D/g;s/+/%2B/g') #Urlencoding some symbols for curl
DISABLE_PREVIEW="${2:-true}"

#/usr/bin/wget -qO- "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendMessage?chat_id=$TG_BOT_CHAT_ID&parse_mode=html&text=$@" 2>&1
/usr/bin/curl --no-progress-meter "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendMessage?chat_id=$TG_BOT_CHAT_ID&parse_mode=HTML&disable_web_page_preview=$DISABLE_PREVIEW&text=$MSG" 2>&1
