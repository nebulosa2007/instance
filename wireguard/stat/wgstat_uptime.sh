#!/bin/bash

#cd /home/$(whoami)/instance/wireguard/var/

#CLIENTS=$(grep "Address" *.conf | sed 's/.conf//;s/Address = //;s/wg0-//;s/:/ /' | tr '\n' '|')

#echo "Statistic from: " $(uptime -s)
#sudo /usr/bin/wg show wg0 | awk '/allowed ips/,/transfer/' |  while read stat_line
#do
#	key_ip=$(echo $stat_line | awk '/allowed ips:/ {print $3}')
#	[ "$key_ip" == "" ]  || (echo -ne "\n" $(echo $CLIENTS | tr '|' '\n' | grep $key_ip | cut -d" " -f1 | sed 's/ //g')) 
#	[ "$(echo $stat_line | grep -E '(peer|preshared|allowed)')" == "" ] && (echo -n $stat_line | sed 's/ day\(s\)*/d/g;s/ minute\(s\)*/m/g;s/ hour\(s\)*/h/g;s/ second\(s\)*/s/g;s/, //g;s/transfer: /  ↑/g;s/received/  ↓/g;s/latest handshake:/: /g;s/ago//;s/ sent//g;') || :
#	[ "$(echo $stat_line | grep 'transfer')" != "" ] && echo || :
#done
/home/$(whoami)/instance/wireguard/stat/wganalyzer.sh | sort -rnk 5 | awk '{printf "%s %-15s\t%6.2f\t%6.2f Gb\n", $1, $2, $5/1000/1000/1000, $5*1.52/1000/1000/1000}' | sed 's/0.00\t  0.00 Gb//g'
