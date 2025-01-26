#!/bin/env bash

publicip=$(curl -qs "https://checkip.amazonaws.com")
port=65535
pubfile="/tmp/key.pub"
[ ! -x /usr/bin/nc ] && sudo pacman -Sy netcat

echo " *  Openning port $port for a while.."
sudo iptables -I INPUT -p tcp --dport $port -j ACCEPT || exit 1

echo "For sending your ssh key, you should do:
cat \"\$HOME/.ssh/id_ed25519.pub\" | nc -cvv $publicip $port"

nc -l -vv -p $port >"$pubfile"

echo " *  Closing port $port"
sudo iptables -D INPUT -p tcp --dport $port -j ACCEPT

if [ -f "$pubfile" ]; then
    echo -e "
    Your key is now located at /tmp/key.pub:
    $(cat $pubfile)\n
    If anything looks good, put this key to your keys:
    cat $pubfile >> ~/.ssh/authorized_keys && rm $pubfile\n
    Good luck!"
else
    echo "No received key file found! Please try again"
fi
