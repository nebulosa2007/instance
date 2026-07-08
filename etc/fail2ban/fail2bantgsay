#!/bin/env bash

# shellcheck source=/dev/null
source /etc/profile.d/instance.sh 2>/dev/null
: "${PATHINSTANCE:?Please set \$PATHINSTANCE env variable!}"

# shellcheck source=/dev/null
source "$PATHINSTANCE"/scripts/sensitive.sh 2>/dev/null

ACTION_TYPE="$1" JAIL_NAME="$2" IP="$3" MATCHES="$4"

if [ "$ACTION_TYPE" = "unban" ]; then
    "$PATHINSTANCE"/scripts/tgsay.sh "♻️ [${JAIL_NAME}] IP unbanned: <code>${IP}</code>"
    exit 0
fi

INPUT_TEXT="[${JAIL_NAME}] IP banned: <code>${IP}</code>
${MATCHES}"

if [ -n "$IP" ]; then
    IFS=',' read -r cc country city asn isp < <(curl -sm3 "http://ip-api.com/csv/$IP?fields=countryCode,country,city,as,isp")
    flag=$(perl -C -e "print map{chr(ord(\$_)+127397)}split//,shift" "$country" 2>/dev/null)
    net=${asn:-$isp}
    info="${flag:- } ${cc:-??}, ${city:-?} / ${net//\"/}"

    sec_json=$(curl -sm3 --get "https://api.ipregistry.co/$IP" -H "Authorization: ApiKey $IPREGISTRY_KEY" --data "fields=security.is_proxy,security.is_vpn,security.is_tor_exit,security.is_relay,security.is_anonymous,security.is_threat,security.is_cloud_provider")
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
