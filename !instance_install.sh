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
sudo cp "$PATHINSTANCE"/etc/sysctl.d/99-highload-sysctl.conf    -t /etc/sysctl.d/
sudo cp "$PATHINSTANCE"/etc/sysctl.d/99-vm-zram-parameters.conf -t /etc/sysctl.d/
sudo sysctl --system
sudo cp "$PATHINSTANCE"/etc/sudoers.d/00_wheel /etc/sudoers.d/00_wheel && sudo chmod -c 0440 /etc/sudoers.d/00_wheel && sudo visudo -c

# Tuming programs
mkdir -p /home/"$(whoami)"/.config/{tmux,yt-dlp,mpv,aria2} /home/"$(whoami)"/.gnupg; chmod 700 ~/.gnupg;
# https://wiki.archlinux.org/title/GnuPG#Searching_and_receiving_keys
ln -sf "$PATHINSTANCE"/config/gpg.conf /home/"$(whoami)"/.gnupg/gpg.conf
# https://wiki.archlinux.org/title/Tmux
ln -sf "$PATHINSTANCE"/config/tmux.conf /home/"$(whoami)"/.config/tmux/tmux.conf
# https://wiki.archlinux.org/title/Yt-dlp
ln -sf "$PATHINSTANCE"/config/yt-dlp-01.conf /home/"$(whoami)"/.config/yt-dlp/config
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


# INSTALL OTHER SOFT

# Nginx server
if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm nginx-mainline
elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y nginx
fi
sudo cp /etc/nginx/nginx.conf{,.backup}
sudo cp "$PATHINSTANCE"/etc/nginx/nginx.conf /etc/nginx/nginx.conf
sudo mkdir -p /etc/nginx/sites-enabled/ /var/www/
sudo cp -vR "$PATHINSTANCE"/etc/nginx/html -t /var/www/
# Optional: some other panel
# sudo cp "$PATHINSTANCE"/etc/nginx/x-ui.conf /etc/nginx/sites-enabled/x-ui.conf

# sudo cp "$PATHINSTANCE"/etc/nginx-routing-update/nginx-routing-update.{service.timer} -t /etc/system/
# sudo systemctl daemon-reload && systemctl enable --now nginx-routing-update.timer && systemctl start nginx-routing-update.service

# Optional: Own arch repository
# sudo cp "$PATHINSTANCE"/etc/nginx/sites-enabled/static_02_repoctl.conf /etc/nginx/sites-enabled/static_02_repoctl.conf
# sudo mkdir -p /home/http/ && sudo chown "$(whoami)":"$(whoami)" /home/http/
# mkdir -p /home/http/archrepo/archive
# cp "$PATHINSTANCE"/etc/nginx/index.html /home/http/archrepo/index.html
# cp "$PATHINSTANCE"/etc/nginx/autoindex.html /home/http/archrepo/autoindex.html
sudo nginx -t && sudo systemctl enable --now nginx


# Firewall
if command -v pacman &>/dev/null; then
    sudo "$PATHINSTANCE"/scripts/firewall-on-nft
elif command -v apt &>/dev/null; then
    sudo "$PATHINSTANCE"/scripts/firewall-on-ufw
fi


# Fail2ban
# See instructions in etc/fail2ban/!install_fail2ban.sh

# TG Daily Stat 
# See instructions in etc/tgdailystat/!install_tgdailystat.sh

# ARCH ONLY

# Install repoctl
paru -Sy --needed repoctl pacman-contrib
sudo mkdir -p /etc/xdg/repoctl
sudo cp "$PATHINSTANCE"/etc/repoctl.toml /etc/xdg/repoctl/config.toml
sudo mkdir -p /home/http/archrepo
sudo chown -R "$USER":"$USER" /home/http/archrepo

# Install a clean build root
# https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot
sudo pacman -Sy --needed devtools
sudo cp "$PATHINSTANCE"/etc/sudoers.d/pkgctl /etc/sudoers.d/pkgctl && sudo chmod -c 0440 /etc/sudoers.d/pkgctl && sudo visudo -c
sudo cp "$PATHINSTANCE"/etc/other/x86_64.conf /usr/share/devtools/makepkg.conf.d/x86_64.conf

# Install update timer
# See instructions in etc/update/install_updatetimer.sh

# Install newrealeases timer
# See instructions in config/newreleases/install_newreleases.sh

# Personal notes, remote repositories
# ssh-keygen -t ed25519 -C $HOSTNAME -N "" -q -f ~/.ssh/id_ed25519_github
# git remote set-url --add --push origin git@...1
# git remote set-url --add --push origin git@...2
# echo "export EDITOR=\"micro\"" | sudo tee -a /etc/profile.d/instance.sh
