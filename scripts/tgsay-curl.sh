#!/bin/bash

source sensitive.sh

if [ -z "$CHAT_ID" ]; then
    echo 'Please, define CHAT_ID first! See "chat":{"id":xxxxxxx string below:'
    #/usr/bin/wget -qO- https://api.telegram.org/bot$API_TOKEN/getUpdates
    /usr/bin/curl https://api.telegram.org/bot$API_TOKEN/getUpdates
    exit 1
fi

#MSG="$@"

#/usr/bin/wget -qO- "https://api.telegram.org/bot$API_TOKEN/sendMessage?chat_id=$CHAT_ID&parse_mode=html&text=$@" 2>&1
/usr/bin/curl "https://api.telegram.org/bot$API_TOKEN/sendMessage?chat_id=$CHAT_ID&parse_mode=html&text=$@" 2>&1

#echo "https://api.telegram.org/bot$API_TOKEN/sendMessage?chat_id=$CHAT_ID&parse_mode=html&text=$@"
#if [ $? -eq 0 ]; then
#    echo 'Message sent successfully.'
#else
#    echo 'Error while sending message!'
#    exit 1
#fi
