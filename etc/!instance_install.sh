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

# 1. Install update timer
# See instructions in update/install_updatetimer.sh

# 2. Install btrfs snapshot hooks for pacman
# See instructions in snapshots/install_snapshots.sh

# 3. Install wireguard and wgstat services 
# See instructions in wireguard/install_wireguard.sh
