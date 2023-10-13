#!/bin/bash

#SERVER_PORT=$(ss -ul | grep -Eo "[0-9]{4,5}")
SERVER_PUB_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"

if [ "$1" == "up" ]
then
  #iptables -I INPUT -p udp --dport $SERVER_PORT -j ACCEPT 
  iptables -I FORWARD -i $SERVER_PUB_NIC -o %i -j ACCEPT
  iptables -I FORWARD -i %i -j ACCEPT
  iptables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
  ip6tables -I FORWARD -i %i -j ACCEPT
  ip6tables -t nat -A POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
else
  if [ "$1" == "down" ]
  then
    #iptables -D INPUT -p udp --dport $SERVER_PORT -j ACCEPT
    iptables -D FORWARD -i $SERVER_PUB_NIC -o %i -j ACCEPT
    iptables -D FORWARD -i %i -j ACCEPT
    iptables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
    ip6tables -D FORWARD -i %i -j ACCEPT
    ip6tables -t nat -D POSTROUTING -o $SERVER_PUB_NIC -j MASQUERADE
  fi
fi
