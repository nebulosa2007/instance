# Tuning network

## /etc/systemd/network/20-ethernet.network
## Name=en*
## Name=eth*
## 
## [Network]
## Gateway=......
## Address=....../32
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
sudo systemctl restart systemd-networkd

# Tuning ssh
# Add .ssh/id_rsa.pub into .ssh/authorized_keys
sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Install programs to instance scripts
pikaur -Syu --needed iproute2 lsd netcat micro mc reflector htop btop expac neofetch ranger tmux

# instance project installing
cd
git clone git@github.com:nebulosa2007/instance.git
ln -s /home/$(whoami)/instance/bashrc .bashrc
ln -s /home/$(whoami)/instance/bash_aliases .bash_aliases
sudo ln -s /home/$(whoami)/instance/etc/tmux.conf /etc/tmux.conf
sudo cp /home/$(whoami)/instance/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf
sudo sysctl --system

# install update timer
cd update
sudo ln -s /home/$(whoami)/instance/update/updpkgs.sh /usr/bin/updpkgs
sudo ln -s /home/$(whoami)/instance/update/update.service /lib/systemd/system/update.service
sudo ln -s /home/$(whoami)/instance/update/update.timer /lib/systemd/system/update.timer
sudo systemctl daemon-reload
sudo systemctl enable --now update.timer

# install vnstat
pikaur -Syu --needed vnstat
vnstat --iflist
sudo vnstat --add -i ens3
sudo systemctl enable --now vnstat

# install localepurge
pikaur -Syu --needed localepurge
sudo ln -s /home/$(whoami)/instance/etc/locale.nopurge /etc/locale.nopurge
sed -i 's/#NoExtract   =/NoExtract   = usr\/share\/man\/* usr\/share\/help\/* usr\/share\/locale\/* !usr\/share\/locale\/en_US* !usr\/share\/locale\/locale.alias/' /etc/pacman.conf

# install wireguard
mkdir wireguard && cd wireguard
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh 
./wireguard-install.sh 
sudo ./wireguard-install.sh 