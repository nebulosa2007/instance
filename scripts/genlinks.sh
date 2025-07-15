#!/bin/bash
# shellcheck source=/dev/null
source /etc/mtproxy.conf || exit 1

: "${SERVER:=$(ip -4 addr show scope global | awk '/inet/ {print $2; exit}' | cut -d/ -f1)}" || {
    echo "Не удалось определить IP" >&2
    exit 1
}
: "${DOMAIN:=$(grep -oP -- '--domain=\K\S+' <<<"$ARGS")}" || {
    echo "Не указан --domain" >&2
    exit 1
}

mapfile -t USERS < <(grep -E -- '^#' /etc/mtproxy.conf | sed 's/^# *//')

index=0
grep -oP -- '--mtproto-secret=\K[a-f0-9]+' <<<"$ARGS" | while read -r s; do
    payload=$(
        printf "\xee"
        echo -n "$s" | sed 's/\(..\)/\\x\1/g' | xargs -0 printf "%b"
        echo -n "$DOMAIN"
    )
    printf "%s: tg://proxy?server=%s&port=%s&secret=%s\n" \
        "${USERS[$index]}" "$SERVER" "${CLIENT_PORT:-443}" \
        "$(echo -n "$payload" | base64 -w0 | tr '+/' '-_' | tr -d '=')"
    ((index++))
done
