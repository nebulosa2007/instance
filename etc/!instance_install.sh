# Instance project set installing:
# IMPORTANT: See notes in .bash_aliases for installing needed packages
cd ~
echo "PATHINSTANCE=\"/home/"$(whoami)"/.config/instance\"" | sudo tee /etc/instance.conf
echo "TG_BOT_API_TOKEN=''" | sudo tee -a /etc/instance.conf
echo "TG_BOT_CHAT_ID=''" | sudo tee -a /etc/instance.conf
source /etc/instance.conf
ln -sf $PATHINSTANCE/bashrc .bashrc
ln -sf  $PATHINSTANCE/bash_aliases .bash_aliases
# Install packages that noted in bash_aliases

# Tuning system
sudo cp $PATHINSTANCE/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf && sudo sysctl --system

# Tuming programs
mkdir -p /home/$(whoami)/.config/{neofetch,tmux,yt-dlp}
ln -sf $PATHINSTANCE/etc/neofetch.conf /home/$(whoami)/.config/neofetch/config.conf
ln -sf $PATHINSTANCE/etc/tmux.conf /home/$(whoami)/.config/tmux/tmux.conf
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
#todo add command to see statistic on 127.0.0.1:8888 outside the server - ssh tunneling
#todo generation link. http://seriyps.ru/mtpgen.html
#todo make aur not git version

# Wireguard server
pikaur -Sy --needed wireguard-ui-bin

# SSLH multiplexor, transparent mode
pikaur -Sy --needed sslh-git
sudo ln -sf $PATHINSTANCE/etc/sslh.cfg /etc/sslh.cfg
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


# 1. Install update timer
# See instructions in update/install_updatetimer.sh
#todo make an aur package ???

# 2. Install btrfs snapshot hooks for pacman
# See instructions in snapshots/install_snapshots.sh

# 3. Install wireguard and wgstat services 
# See instructions in wireguard/install_wireguard.sh

# Remote repositories 
# git remote set-url --add --push origin git@...1
# git remote set-url --add --push origin git@...2
