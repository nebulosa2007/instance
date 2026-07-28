#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

CACHE_DIR="/var/log/ipinfo"
DB="$CACHE_DIR/ipinfo.db"
TTL_SECONDS=$(( 90 * 24 * 3600 ))
MAX_AGE_SECONDS=$(( 180 * 24 * 3600 ))
CLEANUP_MARKER="$CACHE_DIR/.last_cleanup"
CLEANUP_INTERVAL=86400

if ! command -v sqlite3 >/dev/null 2>&1; then
    echo "sqlite3 is required for script" >&2
    exit 1
fi

if [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR" 2>/dev/null
    chmod 700 "$CACHE_DIR" 2>/dev/null
fi

SQLITE=(sqlite3 -cmd ".timeout 5000" -noheader -list)

"${SQLITE[@]}" "$DB" "
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS cache (
    ip   TEXT NOT NULL,
    kind TEXT NOT NULL,
    data TEXT NOT NULL,
    ts   INTEGER NOT NULL,
    PRIMARY KEY (ip, kind)
);
" >/dev/null 2>&1
chmod 600 "$DB" 2>/dev/null

sql_escape() { printf '%s' "$1" | sed "s/'/''/g"; }

cleanup_old_cache() {
    local now last cutoff
    now=$(date +%s)
    if [ -f "$CLEANUP_MARKER" ]; then
        last=$(stat -c %Y "$CLEANUP_MARKER" 2>/dev/null || echo 0)
        (( now - last < CLEANUP_INTERVAL )) && return 0
    fi
    cutoff=$(( now - MAX_AGE_SECONDS ))
    "${SQLITE[@]}" "$DB" "DELETE FROM cache WHERE ts < $cutoff;" >/dev/null 2>&1
    "${SQLITE[@]}" "$DB" "VACUUM;" >/dev/null 2>&1
    touch "$CLEANUP_MARKER" 2>/dev/null
}

# cache_get <ip> <kind> <ttl_seconds>  -> печатает данные, если запись свежая
cache_get() {
    local ip="$1" kind="$2" ttl="$3" now cutoff
    now=$(date +%s)
    cutoff=$(( now - ttl ))
    "${SQLITE[@]}" "$DB" "SELECT data FROM cache WHERE ip='$(sql_escape "$ip")' AND kind='$kind' AND ts > $cutoff;" 2>/dev/null
}

# cache_set <ip> <kind> <data>
cache_set() {
    local ip="$1" kind="$2" data="$3" now
    now=$(date +%s)
    "${SQLITE[@]}" "$DB" "INSERT OR REPLACE INTO cache (ip, kind, data, ts) VALUES ('$(sql_escape "$ip")', '$kind', '$(sql_escape "$data")', $now);" >/dev/null 2>&1
}

# get_cached_or_fetch <ip> <kind> <ttl_seconds> <shell_command_string>
get_cached_or_fetch() {
    local ip="$1" kind="$2" ttl="$3" fetch_cmd="$4" cached result
    cached=$(cache_get "$ip" "$kind" "$ttl")
    if [ -n "$cached" ]; then
        printf '%s' "$cached"
        return 0
    fi
    result=$(eval "$fetch_cmd")
    cache_set "$ip" "$kind" "$result"
    printf '%s' "$result"
}

cleanup_old_cache

ACTION_TYPE="$1" JAIL_NAME="$2" IP="$3" MATCHES="$4"

if [ "$ACTION_TYPE" = "unban" ]; then
    "$PATHINSTANCE"/scripts/tgsay.sh "♻️ [${JAIL_NAME}] IP unbanned: <code>${IP}</code>"
    exit 0
fi

INPUT_TEXT="[${JAIL_NAME}] IP banned: <code>${IP}</code>
${MATCHES}"

if [ -n "$IP" ]; then
    geo_csv=$(get_cached_or_fetch "$IP" "geo" "$TTL_SECONDS" \
        "curl -sm3 'http://ip-api.com/csv/$IP?fields=countryCode,country,city,as,isp'")
    IFS=',' read -r cc country city asn isp <<<"$geo_csv"

    flag=$(perl -C -e "print map{chr(ord(\$_)+127397)}split//,shift" "$country" 2>/dev/null)
    net=${asn:-$isp}
    info="${flag:- } ${cc:-??}, ${city:-?} / ${net//\"/}"

    sec_json=$(get_cached_or_fetch "$IP" "sec" "$TTL_SECONDS" \
        "curl -sm3 --get 'https://api.ipregistry.co/$IP' -H 'Authorization: ApiKey $IPREGISTRY_KEY' --data 'fields=security.is_proxy,security.is_vpn,security.is_tor_exit,security.is_relay,security.is_anonymous,security.is_threat,security.is_cloud_provider'")
    jget() { grep -oP "\"$1\":\K(true|false)" <<<"$sec_json"; }

    hits=()
    [[ $(jget is_cloud_provider) == true ]] && hits+=("Server 🚩")
    privacy=()
    [[ $(jget is_proxy) == true ]]     && privacy+=("Proxy")
    [[ $(jget is_vpn) == true ]]       && privacy+=("VPN")
    [[ $(jget is_tor_exit) == true ]]  && privacy+=("Tor")
    [[ $(jget is_anonymous) == true ]] && privacy+=("Anonymous")
    [[ $(jget is_relay) == true ]]     && privacy+=("Relay")
    ((${#privacy[@]})) && hits+=("$(IFS=,; echo "${privacy[*]}" | sed 's/,/, /g') 🚩")
    [[ $(jget is_threat) == true ]] && hits+=("Abuser 🚩")
    ip_line=$( ((${#hits[@]})) && { IFS='|'; echo "${hits[*]}" | sed 's/|/ | /g'; } || echo "<code>-</code>")
fi

MSG=$(awk -v info="${info:-}" -v ip_line="${ip_line:-}" '
    NR==1 && /IP banned/ { print "\n"$0"\n" info "\n" ip_line; next }
    /\[[0-9]{2}\/[A-Za-z]{3}\/202[0-9]:/ || /202[0-9]-/ {
        if (/ 444 / || /nginx/) { split($0,a,"\""); print "<pre><code class=\"language-log\">"a[2]"\n"a[4]"\n"a[6]"</code></pre>"; next }
        if (/sshd/)             { sub(/^.*]: /,""); gsub("</pre>","</code></pre>"); print "<pre><code class=\"language-log\">"$0; next }
    }1
' <<<"🚫 $INPUT_TEXT")

"$PATHINSTANCE"/scripts/tgsay.sh "$MSG" || :
exit 0
