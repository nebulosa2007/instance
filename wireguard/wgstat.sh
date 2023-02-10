#!/bin/bash

cd /home/$(whoami)/instance/wireguard/var/

CLIENTS=$(grep "Address" *.conf | sed 's/.conf//;s/Address = //;s/wg0-//;s/:/ /' | tr '\n' '|')

echo "Statistic from: " $(uptime -s)
echo
sudo /usr/bin/wg show wg0 | awk '/allowed ips/,/transfer/' |  while read stat_line
do
	key_ip=$(echo $stat_line | awk '/allowed ips:/ {print $3}')
	[ "$key_ip" == "" ] || (echo -e "Client:" $(echo $CLIENTS | tr '|' '\n' | grep $key_ip | cut -d" " -f1))
	[ "$(echo $stat_line | grep -E '(peer|preshared|allowed)')" == "" ] && echo $stat_line || :
	[ "$(echo $stat_line | grep 'transfer')" != "" ] && echo || :
done
