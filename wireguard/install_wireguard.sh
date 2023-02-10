#!/bin/bash

#Lasy install wireguard server. WARNING: this setup wouldn't work with wg-gui etc.

mkdir -p var && cd var

#Credits: https://github.com/angristan/wireguard-install
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh

# Best practic will be save all *.conf files in var directory
