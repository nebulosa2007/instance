# Instance project set installing:
# IMPORTANT: See notes in .bash_aliases for installing needed packages
cd ~
ln -sf /home/$(whoami)/instance/bashrc .bashrc
ln -s /home/$(whoami)/instance/bash_aliases .bash_aliases

# Tuning system
sudo cp /home/$(whoami)/instance/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf && sysctl --system

# 1. Install update timer
# See instructions in update/install_updatetimer.sh

# 2. Install btrfs snapshot hooks for pacman
# See instructions in snapshots/install_snapshots.sh

# 3. Install wireguard and wgstat services 
# See instructions in wireguard/install_wireguard.sh
