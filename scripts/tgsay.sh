#!/bin/bash

source /etc/instance.conf
source $PATHINSTANCE/scripts/sensitive.sh

if [ -z "$CHAT_ID" ]; then
    echo 'Please, define CHAT_ID and API_TOKEN first! See "chat":{"id":xxxxxxx string below from request: curl https://api.telegram.org/bot$API_TOKEN/getUpdates'
    exit 1
fi

MSG=$(echo "$@" | tr '\n' '[' | sed 's/ /%20/g;s/\[/%0A/g') #Urlencoding some simbols for curl

#/usr/bin/wget -qO- "https://api.telegram.org/bot$API_TOKEN/sendMessage?chat_id=$CHAT_ID&parse_mode=html&text=$@" 2>&1
/usr/bin/curl "https://api.telegram.org/bot$API_TOKEN/sendMessage?chat_id=$CHAT_ID&parse_mode=HTML&text=$MSG" 2>&1
