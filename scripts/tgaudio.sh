#!/bin/env bash

: "${1:?Usage: $0 \"FILE\" \"[caption]\" \"[author]\" \"[title]\"}"

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

: "${TG_BOT_CHAT_ID:?Please, define TG_BOT_CHAT_ID and TG_BOT_API_TOKEN first! To get TG_BOT_CHAT_ID, run the following command and look for the \"chat\":{\"id\":xxxxxxx string: curl -s https://api.telegram.org/bot$TG_BOT_API_TOKEN/getUpdates}"

/usr/bin/curl --no-progress-meter \
              -F audio=@"$1" \
              -F caption="$2" \
              -F performer="$3" \
              -F title="$4" \
              -F chat_id="$TG_BOT_CHAT_ID" \
              -F parse_mode="HTML" \
              "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendAudio" 2>&1
