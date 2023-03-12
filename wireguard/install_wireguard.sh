#!/bin/bash

# Lasy install wireguard server. WARNING: this setup wouldn't work with wg-gui etc.

cd /home/$(whoami)/instance/wireguard/
mkdir -p var && cd var

# Credits: https://github.com/angristan/wireguard-install
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh

# Please save all *.conf files in var directory

# For wgstat for TG script without sudo
echo "%wheel ALL=(ALL:ALL) NOPASSWD:/usr/bin/wg show wg0" | sudo tee /etc/sudoers.d/wgstatus
sudo chmod 440 /etc/sudoers.d/wgstatus
sudo visudo -c

# Install wgstat service
sudo cp /home/$(whoami)/instance/wireguard/stat/wgstat /usr/bin/wgstat
sudo cp /home/$(whoami)/instance/wireguard/stat/wgstat.service /lib/systemd/system/wgstat.service
sudo cp /home/$(whoami)/instance/wireguard/stat/wgstat.timer /lib/systemd/system/wgstat.timer
sudo systemctl daemon-reload
sudo systemctl enable --now wgstat.timer
