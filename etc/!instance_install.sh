# Instance project set installing:
# IMPORTANT: See notes in .bash_aliases for installing needed packages
cd ~
echo "PATHINSTANCE=\"/home/"$(whoami)"/.config/instance\"" | sudo tee /etc/instance.conf
echo "TG_BOT_API_TOKEN=''" | sudo tee -a /etc/instance.conf
echo "TG_BOT_CHAT_ID=''" | sudo tee -a /etc/instance.conf
source /etc/instance.conf
ln -sf $PATHINSTANCE/bashrc .bashrc
ln -sf  $PATHINSTANCE/bash_aliases .bash_aliases

# Tuning system
sudo cp $PATHINSTANCE/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf && sudo sysctl --system

# Tuming programs
mkdir -p /home/$(whoami)/.config/{neofetch,tmux}
ln -sf $PATHINSTANCE/etc/neofetch.conf /home/$(whoami)/.config/neofetch/config.conf
ln -sf $PATHINSTANCE/etc/tmux.conf /home/$(whoami)/.config/tmux/tmux.conf

# Telegram proxy
pikaur -Syu mtproxy-git
echo cp $PATHINSTANCE/etc/mtproxy.conf /etc/mtproxy.conf
sudo sed -i 's/SECRET=\'\'/SECRET='$(head -c 16 /dev/urandom | xxd -ps)'/' /etc/mtproxy.conf
sudo systemctl enable -now mtproxy mtproxy-config.timer 

# Tuning sshd server (in case the host is remote)
# On client host:
# ssh-keygen -t ed25519 && ssh-copy-id -i $HOME/.ssh/id_ed25519.pub user@ip_server
sudo ln -sf $PATHINSTANCE/etc/sshdloginkeyonly.conf /etc/ssh/sshd_config.d/sshdloginkeyonly.conf
sudo systemctl reload sshd
# DOUBLE CHECK
sudo sshd -T | grep -E -i 'PasswordAuthentication|PermitRootLogin'
# On client host, testing:
# ssh root@ip_server  - should be: Permission denied (publickey).
# ssh -o PubkeyAuthentication=no user@ip_server - should be: Permission denied (publickey).


# 1. Install update timer
# See instructions in update/install_updatetimer.sh

# 2. Install btrfs snapshot hooks for pacman
# See instructions in snapshots/install_snapshots.sh

# 3. Install wireguard and wgstat services 
# See instructions in wireguard/install_wireguard.sh
