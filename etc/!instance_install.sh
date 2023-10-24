# Instance project set installing:
# IMPORTANT: See notes in .bash_aliases for installing needed packages

echo "PATHINSTANCE=\"/home/"$(whoami)"/.config/instance\"" | sudo tee /etc/instance.conf
echo "TG_BOT_API_TOKEN=''" | sudo tee -a /etc/instance.conf
echo "TG_BOT_CHAT_ID=''"   | sudo tee -a /etc/instance.conf
source /etc/instance.conf
ln -sf $PATHINSTANCE/bashrc       /home/($whoami)/.bashrc
ln -sf $PATHINSTANCE/bash_aliases /home/($whoami)/.bash_aliases
# Install packages that pointed in bash_aliases

# Tuning system
sudo cp $PATHINSTANCE/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf && sudo sysctl --system

# Tuming programs
mkdir -p /home/$(whoami)/.config/{neofetch,tmux,yt-dlp}
ln -sf $PATHINSTANCE/etc/neofetch.conf /home/$(whoami)/.config/neofetch/config.conf
# https://wiki.archlinux.org/title/Tmux
ln -sf $PATHINSTANCE/etc/tmux.conf /home/$(whoami)/.config/tmux/tmux.conf
# https://wiki.archlinux.org/title/Yt-dlp
ln -sf $PATHINSTANCE/etc/yt-dlp.conf /home/$(whoami)/.config/yt-dlp/config


# Tuning sshd server (in case the host is remote)
# On client host:
# ssh-keygen -t ed25519 && ssh-copy-id -i $HOME/.ssh/id_ed25519.pub user@ip_server
sudo ln -sf $PATHINSTANCE/etc/sshd.conf /etc/ssh/sshd_config.d/sshd.conf
sudo systemctl reload sshd
# DOUBLE CHECK
sudo sshd -T | grep -E -i 'PasswordAuthentication|PermitRootLogin|MaxAuthTries'
# On client host, testing:
# ssh root@ip_server  - should be: Permission denied (publickey).
# ssh -o PubkeyAuthentication=no user@ip_server - should be: Permission denied (publickey).


# Telegram server
pikaur -S --needed  mtproxy-git
sudo cp $PATHINSTANCE/etc/mtproxy.conf /etc/mtproxy.conf
sudo sed -i 's/SECRET=/SECRET='$(tr -dc 'a-f0-9' < /dev/urandom | dd bs=1 count=32 2>/dev/null)'/' /etc/mtproxy.conf
sudo systemctl enable --now mtproxy mtproxy-config.timer
# generation link: http://seriyps.ru/mtpgen.html Fake-TLS base64 link needed


# Wireguard server
pikaur -Sy --needed wireguard-ui-bin
# Read notes after install
# IPv6 config:
# Add in Server Interface Addresses - fd42:42:42::0/64
# Add in DNS Servers - 2620:fe::fe (free DNS resolver from Quad9)
# When you will create new user add at Allowed IPs section - ::/0 (not included automatically)
# Test your WG connection here: https://ipv6-test.com - ISPs for IPv4 and IPv6 will be the same


# SSLH multiplexor
# https://wiki.archlinux.org/title/Sslh
pikaur -Sy --needed sslh
sudo cp $PATHINSTANCE/etc/sslh.cfg /etc/sslh.cfg
sudo systemctl daemon-reload
sudo cp /run/systemd/generator/sslh.socket /etc/systemd/system/sslh.socket
printf "\n[Install]\nWantedBy = multi-user.target" | sudo tee -a  /etc/systemd/system/sslh.socket
sudo systemctl enable --now sslh.socket

#todo make aur package with transparent mode:
#sudo cp $PATHINSTANCE/etc/99-sslh.conf /etc/sysctl.d/99-sslh.conf && sudo sysctl --system
#sudo useradd -mG wheel --system -s /usr/bin/nologin sslh
#sudo systemctl enable sslh-fork.service
# Configure routing for those marked packets
#sudo ip rule add fwmark 0x1 lookup 100
#sudo ip route add local 0.0.0.0/0 dev lo table 100
# And required firewall on


# Firewall
sudo $PATHINSTANCE/scripts/firewall-on
# After firewall setup
sudo systemctl restart wg-quick@wg0


# Snapshots
# https://wiki.archlinux.org/title/Yabsnap

#For minimizing size of snapshots
sudo rm -f /var/cache/pacman/pkg/*
sudo sed -i 's/#CacheDir    = \/var\/cache\/pacman\/pkg\//CacheDir     = \/tmp\//' /etc/pacman.conf
pikaur -Sy --needed yabsnap
sudo yabsnap create-config root      #for root partittion
sudo sed -i 's/source=/source=\//' /etc/yabsnap/configs/root.conf
sudo systemctl enable --now yabsnap.timer

# 1. Install update timer
# See instructions in update/install_updatetimer.sh

# 2. Install wgstat services
# See instructions in wireguard/install_wireguard.sh
#todo need update due wireguard-ui!


# Personal notes, remote repositories
# git remote set-url --add --push origin git@...1
# git remote set-url --add --push origin git@...2
