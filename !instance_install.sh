#!/bin/false
# shellcheck shell=bash

# Instance project set installing:
# IMPORTANT: See notes in .bash_aliases for installing needed packages

echo "export PATHINSTANCE=\"/home/$(whoami)/.config/instance\"" | sudo tee /etc/profile.d/instance.sh
# shellcheck source=/dev/null
source /etc/profile.d/instance.sh
printf "TG_BOT_API_TOKEN='' \n TG_BOT_CHAT_ID='' LIMIT=''" >>"$PATHINSTANCE"/scripts/sensitive.sh
ln -sf "$PATHINSTANCE"/bashrc /home/"$(whoami)"/.bashrc
ln -sf "$PATHINSTANCE"/bash_aliases /home/"$(whoami)"/.bash_aliases
# Install packages that pointed in bash_aliases

# Tuning system
sudo cp "$PATHINSTANCE"/etc/sysctl.d/50-coredump.conf /etc/sysctl.d/50-coredump.conf
sudo cp "$PATHINSTANCE"/etc/sysctl.d/99-sysctl.conf   /etc/sysctl.d/99-sysctl.conf
sudo cp "$PATHINSTANCE"/etc/sysctl.d/99-sysctl.conf   /etc/sysctl.d/99-vm-zram-parameters.conf
sudo sysctl --system
sudo cp "$PATHINSTANCE"/etc/sudoers.d/00_wheel /etc/sudoers.d/00_wheel && chmod -c 0440 /etc/sudoers.d/00_wheel && visudo -c

# Tuming programs
mkdir -p /home/"$(whoami)"/.config/{tmux,yt-dlp,mpv,aria2} /home/"$(whoami)"/.gnupg
# https://wiki.archlinux.org/title/GnuPG#Searching_and_receiving_keys
ln -sf "$PATHINSTANCE"/config/gpg.conf /home/"$(whoami)"/.gnupg/gpg.conf
# https://wiki.archlinux.org/title/Tmux
ln -sf "$PATHINSTANCE"/config/tmux.conf /home/"$(whoami)"/.config/tmux/tmux.conf
# https://wiki.archlinux.org/title/Yt-dlp
ln -sf "$PATHINSTANCE"/config/yt-dlp.conf /home/"$(whoami)"/.config/yt-dlp/config
# https://wiki.archlinux.org/title/Mpv
ln -sf "$PATHINSTANCE"/config/mpv.conf /home/"$(whoami)"/.config/mpv/mpv.conf
# https://wiki.archlinux.org/title/Aria2
ln -sf "$PATHINSTANCE"/config/aria2.conf /home/"$(whoami)"/.config/aria2/aria2.conf
# Optinal for micro
ln -sf "$PATHINSTANCE"/config/micro.json /home/"$(whoami)"/.config/micro/settings.json

# Tuning sshd server (in case the host is remote)
# On client host:
# ssh-keygen -t ed25519 && ssh-copy-id -i $HOME/.ssh/id_ed25519.pub user@ip_server
sudo cp "$PATHINSTANCE"/etc/sshd.conf /etc/ssh/sshd_config.d/sshd.conf
sudo systemctl reload sshd
# DOUBLE CHECK
sudo sshd -T | grep -E -i 'PasswordAuthentication|PermitRootLogin|MaxAuthTries'
# On client host, testing:
# ssh root@ip_server  - should be: Permission denied (publickey).
# ssh -o PubkeyAuthentication=no user@ip_server - should be: Permission denied (publickey).

# Install a clean build root
# https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot
pacman -Sy --needed devtools
sudo cp "$PATHINSTANCE"/etc/sudoers.d/pkgctl /etc/sudoers.d/pkgctl && chmod -c 0440 /etc/sudoers.d/pkgctl && visudo -c

# Wireguard
# https://wiki.archlinux.org/title/WireGuard#wg-quick
pacman -Sy --needed wireguard-tools
sudo mkdir -p /etc/wireguard
sudo wg showconf wg0 | sudo tee /etc/wireguard/wg0.conf
sudo systemctl enable --now wg-quick@wg0.service
sudo vnstat --add -i wg0

# Nginx server
paru -Sy --needed nginx-mainline
sudo cp /etc/nginx/nginx.conf{,.backup}
sudo cp "$PATHINSTANCE"/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo mkdir -p /etc/nginx/sites-enabled/
sudo mkdir -p /home/http/ && sudo chown "$(whoami)":"$(whoami)" /home/http/

# Optional: Own arch repository
# sudo cp "$PATHINSTANCE"/etc/nginx/static_02_repoctl.conf /etc/nginx/sites-enabled/static_02_repoctl.conf
# mkdir -p /home/http/archrepo/archive
# cp "$PATHINSTANCE"/etc/nginx/index.html /home/http/archrepo/index.html
# cp "$PATHINSTANCE"/etc/nginx/autoindex.html /home/http/archrepo/autoindex.html

# Optional: Nginx logs
# sudo cp "$PATHINSTANCE"/etc/nginx/static_03_logs.conf /etc/nginx/sites-enabled/static_03_logs.conf

# Optional: some other panel
# sudo cp "$PATHINSTANCE"/etc/nginx/5443_x-ui.conf /etc/nginx/sites-enabled/5443_x-ui.conf

sudo nginx -t && sudo systemctl enable --now nginx

# Install haproxy
sudo pacman -Syu haproxy
sudo cp "$PATHINSTANCE"/etc/haproxy.cfg  /etc/haproxy/haproxy.cfg

# Firewall
sudo "$PATHINSTANCE"/scripts/firewall-on
# After firewall setup
sudo systemctl restart wg-quick@wg0

# For fail2ban
sudo pacman -Syu fail2ban ipset
sudo cp "$PATHINSTANCE"/etc/fail2ban/jail.local              /etc/fail2ban/jail.local
sudo cp "$PATHINSTANCE"/etc/fail2ban/fail2ban.local          /etc/fail2ban/fail2ban.local
sudo cp "$PATHINSTANCE"/etc/fail2ban/telegram-notify.local   /etc/fail2ban/action.d/telegram-notify.local
sudo cp "$PATHINSTANCE"/etc/fail2ban/iptables-ipset.local    /etc/fail2ban/action.d/iptables-ipset.local
sudo cp "$PATHINSTANCE"/etc/fail2ban/nginx-bad-request.local /etc/fail2ban/filter.d/nginx-bad-request.local
sudo cp "$PATHINSTANCE"/etc/fail2ban/jail2bantgsay           /usr/local/bin/jail2bantgsay
sudo systemctl enable --now fail2ban

# Install repoctl
paru -Sy --needed repoctl
sudo cp /etc/xdg/repoctl/config.toml{,.backup}
sudo cp "$PATHINSTANCE"/etc/repoctl.toml /etc/xdg/repoctl/config.toml

# Install update timer
# See instructions in etc/update/install_updatetimer.sh

# Install newrealeases timer
# See instructions in config/newreleases/install_newreleases.sh

# Personal notes, remote repositories
# git remote set-url --add --push origin git@...1
# git remote set-url --add --push origin git@...2
# echo "export EDITOR=\"micro\"" | sudo tee -a /etc/profile.d/instance.sh
