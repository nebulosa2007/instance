#!/bin/bash

source /etc/instance.conf

eth=$(vnstat -i ens3 -m 1 --oneline | cut -d";" -f 11 | cut -d" " -f1)
 wg=$(vnstat -i wg0  -m 1 --oneline | cut -d";" -f 11 | cut -d" " -f1)

echo '```'
printf "        Client     wg       eth    Gbs per day\n"
$PATHINSTANCE/wireguard/stat/wgstat_analyzer.sh | sort -rnk 5 | awk '{printf "%14s %8.2f %8.2f %8.2f\n", $2, $5/1000/1000/1000, $5*'$eth'/'$wg'/1000/1000/1000, $5/'$(date '+%d')'/1000/1000/1000}' | sed 's/0.00     0.00     0.00//g'
echo '```'
