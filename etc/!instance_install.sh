#!/bin/false
# shellcheck shell=bash

# Instance project set installing:
# IMPORTANT: See notes in .bash_aliases for installing needed packages

echo "export PATHINSTANCE=\"/home/$(whoami)/.config/instance\"" | sudo tee /etc/profile.d/instance.sh
source /etc/profile.d/instance.sh
printf "TG_BOT_API_TOKEN='' \n TG_BOT_CHAT_ID='' LIMIT=''" >> "$PATHINSTANCE"/scripts/sensitive.sh
ln -sf "$PATHINSTANCE"/bashrc       /home/"$(whoami)"/.bashrc
ln -sf "$PATHINSTANCE"/bash_aliases /home/"$(whoami)"/.bash_aliases
# Install packages that pointed in bash_aliases

# Tuning system
sudo cp "$PATHINSTANCE"/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf && sudo sysctl --system

# Tuming programs
mkdir -p /home/"$(whoami)"/.config/{neofetch,tmux,yt-dlp}
ln -sf "$PATHINSTANCE"/etc/neofetch.conf /home/"$(whoami)"/.config/neofetch/config.conf
# https://wiki.archlinux.org/title/GnuPG#Searching_and_receiving_keys
mkdir /home/"$(whoami)"/.gnupg
ln -sf "$PATHINSTANCE"/etc/gpg.conf /home/"$(whoami)"/.gnupg/gpg.conf
# https://wiki.archlinux.org/title/Tmux
ln -sf "$PATHINSTANCE"/etc/tmux.conf /home/"$(whoami)"/.config/tmux/tmux.conf
# https://wiki.archlinux.org/title/Yt-dlp
ln -sf "$PATHINSTANCE"/etc/yt-dlp.conf /home/"$(whoami)"/.config/yt-dlp/config
# https://wiki.archlinux.org/title/Mpv
ln -sf "$PATHINSTANCE"/etc/mpv.conf /home/"$(whoami)"/.config/mpv/mpv.conf

# Optinal for micro
ln -sf "$PATHINSTANCE"/etc/micro.json /home/"$(whoami)"/.config/micro/settings.json

# Tuning sshd server (in case the host is remote)
# On client host:
# ssh-keygen -t ed25519 && ssh-copy-id -i $HOME/.ssh/id_ed25519.pub user@ip_server
sudo ln -sf "$PATHINSTANCE"/etc/sshd.conf /etc/ssh/sshd_config.d/sshd.conf
sudo systemctl reload sshd
# DOUBLE CHECK
sudo sshd -T | grep -E -i 'PasswordAuthentication|PermitRootLogin|MaxAuthTries'
# On client host, testing:
# ssh root@ip_server  - should be: Permission denied (publickey).
# ssh -o PubkeyAuthentication=no user@ip_server - should be: Permission denied (publickey).


# Telegram server
pikaur -S --needed  mtproxy-git
sudo cp "$PATHINSTANCE"/etc/mtproxy.conf /etc/mtproxy.conf
sudo sed -i 's/SECRET=/SECRET='"$(tr -dc 'a-f0-9' < /dev/urandom | dd bs=1 count=32 2>/dev/null)"'/' /etc/mtproxy.conf
sudo systemctl enable --now mtproxy mtproxy-config.timer
# generation link: http://seriyps.ru/mtpgen.html Fake-TLS base64 link needed


# Wireguard server
pikaur -Sy --needed wireguard-ui
sudo systemctl enable --now wireguard-ui
# Read notes after install
# IPv6 config:
# Add in Server Interface Addresses - fd42:42:42::0/64
# Add in DNS Servers - 2620:fe::fe (free DNS resolver from Quad9)
# When you will create new user add at Allowed IPs section - ::/0 (not included automatically)
# Test your WG connection here: https://ipv6-test.com - ISPs for IPv4 and IPv6 will be the same
sudo systemctl enable --now wgui.{service,path}
sudo vnstat --add -i wg0


# Nginx server
pikaur -Sy --needed nginx-mainline
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo cp "$PATHINSTANCE"/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo mkdir -p /etc/nginx/sites-enabled/
sudo mkdir -p /home/http/ && sudo chown "$(whoami)":"$(whoami)" /home/http/
# Wireguard UI
sudo cp "$PATHINSTANCE"/etc/nginx/80_04_wireguard-ui.conf /etc/nginx/sites-enabled/80_04_wireguard-ui.conf
# Telegram proxy link generator
sudo cp "$PATHINSTANCE"/etc/nginx/80_01_mtproxy.conf /etc/nginx/sites-enabled/80_01_mtproxy.conf
mkdir -p /home/http/mtproto
cp "$PATHINSTANCE"/etc/nginx/mtpgen.html /home/http/mtproto/index.html
# Optional: Own arch repository
# sudo cp "$PATHINSTANCE"/etc/nginx/80_02_repoctl.conf /etc/nginx/sites-enabled/80_02_repoctl.conf
# mkdir -p /home/http/archrepo
# mkdir -p /home/http/archrepo/archive
# cp "$PATHINSTANCE"/etc/nginx/index.html /home/http/archrepo/index.html
# cp "$PATHINSTANCE"/etc/nginx/autoindex.html /home/http/archrepo/autoindex.html

# Optional: some other panel
# sudo cp "$PATHINSTANCE"/etc/nginx/80_03_ppanel.conf /etc/nginx/sites-enabled/80_03_ppanel.conf

# Optional: NGINX as multiplexer OR use SSLH multiplexer below
# sudo cp "$PATHINSTANCE"/etc/nginx/443_01_multiplexer.conf /etc/nginx/sites-enabled/443_01_multiplexer.conf

sudo nginx -t && sudo systemctl enable --now nginx 


# SSLH multiplexer
# https://wiki.archlinux.org/title/Sslh
pikaur -Sy --needed sslh
sudo cp "$PATHINSTANCE"/etc/sslh.cfg /etc/sslh.cfg
sudo systemctl daemon-reload
sudo systemctl enable --now sslh-fork.service

# Firewall
sudo "$PATHINSTANCE"/scripts/firewall-on
# After firewall setup
sudo systemctl restart wg-quick@wg0

# Snapshots
# https://wiki.archlinux.org/title/Yabsnap
#For minimizing size of snapshots
sudo rm -f /var/cache/pacman/pkg/*
sudo sed -i 's/#CacheDir    = \/var\/cache\/pacman\/pkg\//CacheDir     = \/tmp\//' /etc/pacman.conf
pikaur -Sy --needed yabsnap
sudo yabsnap create-config root   #for root partittion
sudo sed -i 's/source=/source=\//' /etc/yabsnap/configs/root.conf
sudo systemctl enable --now yabsnap.timer

# Install update timer
# See instructions in update/install_updatetimer.sh


# Personal notes, remote repositories
# git remote set-url --add --push origin git@...1
# git remote set-url --add --push origin git@...2
# echo "export EDITOR=\"micro\"" | sudo tee -a /etc/profile.d/instance.sh
