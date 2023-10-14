#!/bin/bash

source /etc/wireguard/params 

if [ "$1" == "up" ]
then
  iptables -I INPUT -p udp --dport ${SERVER_PORT} -j ACCEPT
  iptables -I FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT
  iptables -I FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
  iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
  ip6tables -I FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
  ip6tables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
else
  if [ "$1" == "down" ]
  then
    iptables -D INPUT -p udp --dport ${SERVER_PORT} -j ACCEPT
    iptables -D FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT
    iptables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
    iptables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
    ip6tables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
    ip6tables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
   fi
fi
