#!/bin/bash
CONFIG="/etc/wireguard/wg0.conf"
CLIENTS=$(sudo awk '/###/;/Allowed/{print $NF}' $CONFIG | tr '\n' ' ' | sed 's/,/, /g;s/ ### /\n|/g;s/### //;s/Client //g')

echo "Statistic from: " $(uptime -s)
echo
sudo wg | awk '/allowed ips/,/transfer/' |  while read stat_line
do
	key_ip=$(echo $stat_line | awk '/allowed ips:/ {print $3}')
	if [ "$key_ip" == "" ]
	then
		client_name=""
	else
		client_name=$(echo $CLIENTS | tr '|' '\n' | grep $key_ip | cut -d" " -f1)
		echo "Client: "$client_name
	fi
	if [ "$(echo $stat_line | grep -E '(peer|preshared|allowed)')" == "" ]
	then
		echo $stat_line
	fi
	if [ "$(echo $stat_line | grep 'transfer')" != "" ]
	then
		echo
	fi
done
