#!/bin/false
# shellcheck shell=bash

#fail2ban module of Instance project

sudo pacman -Syu fail2ban
sudo cp "$PATHINSTANCE"/etc/fail2ban/{telegram-geo,nftables,ufw}.local -t /etc/fail2ban/action.d
sudo cp "$PATHINSTANCE"/etc/fail2ban/{recidive,nginx-444}.local        -t /etc/fail2ban/filter.d
sudo cp "$PATHINSTANCE"/etc/fail2ban/jail.local                        -t /etc/fail2ban
sudo cp "$PATHINSTANCE"/etc/fail2ban/f2b-telegram.sh                   -t /usr/local/bin

sudo fail2ban-client -d
sudo systemctl enable --now fail2ban
