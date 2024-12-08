#!/bin/env bash

PUBLIC_IP=$(curl -qs "https://checkip.amazonaws.com")
PORT=65535
[ -x /usr/bin/nc ] && sudo pacman -Sy netcat

echo " *  Openning port $PORT for a while.."
sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT || exit 1

echo "For sending your ssh key, you should do:
cat \"~.ssh/id_ed25519.pub\" | nc $PUBLIC_IP $PORT"

nc -l -vv -p $PORT > /tmp/key.pub

echo " *  Closing port $PORT"
sudo iptables -A INPUT -p tcp --dport $PORT -j DROP || exit 3

echo "Your key now is located at /tmp/key.pub:"
cat /tmp/key.pub || exit 4
echo "If anything looks good, so put this key to your keys:
cat /tmp/key.pub >> ~/.ssh/authorized_keys"
echo "Good luck!"
