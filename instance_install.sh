# Install programs to instance scripts
pikaur -Syu --needed lsd mc reflector expac tmux

# instance project installing
cd
git clone git@github.com:nebulosa2007/instance.git
ln -sf /home/$(whoami)/instance/bashrc .bashrc
ln -s /home/$(whoami)/instance/bash_aliases .bash_aliases
sudo ln -s /home/$(whoami)/instance/etc/tmux.conf /etc/tmux.conf
sudo cp /home/$(whoami)/instance/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf
sudo sysctl --system

# install update timer (ln is only one drive for / and /home!! if not, use cp instead)
cd instance/update
sudo ln -s /home/$(whoami)/instance/update/updpkgs.sh /usr/bin/updpkgs
sudo ln -s /home/$(whoami)/instance/update/update.service /lib/systemd/system/update.service
sudo ln -s /home/$(whoami)/instance/update/update.timer /lib/systemd/system/update.timer
sudo systemctl daemon-reload
sudo systemctl enable --now update.timer
