#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

: "${TG_BOT_CHAT_ID:?Please, define TG_BOT_CHAT_ID and TG_BOT_API_TOKEN first! To get TG_BOT_CHAT_ID, run the following command and look for the \"chat\":{\"id\":xxxxxxx string: curl -s https://api.telegram.org/bot$TG_BOT_API_TOKEN/getUpdates}"

/usr/bin/curl --no-progress-meter \
              -F chat_id="$TG_BOT_CHAT_ID" \
              -F parse_mode="HTML" \
               --form-string text="$1" \
              -F link_preview_options='{"is_disabled":'"${2:-true}"'}' \
              "https://api.telegram.org/bot$TG_BOT_API_TOKEN/sendMessage" 2>&1
