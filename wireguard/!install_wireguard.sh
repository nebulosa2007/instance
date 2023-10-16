#Wireguard module of Instance project

#source /etc/instance.conf
#cd $PATHINSTANCE/wireguard
#mkdir -p var && cd var

# https://github.com/angristan/wireguard-install
# curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
# chmod +x wireguard-install.sh
# sudo ./wireguard-install.sh
# # you need install server only!
# sudo systemctl stop wg-quick@wg0

# https://github.com/ngoduykhanh/wireguard-ui
# Install wireguard-tools
# sudo curl -sL $(curl -s https://api.github.com/repos/ngoduykhanh/wireguard-ui/releases/latest | grep -Eom1 "https://.*linux-amd64.tar.gz") | sudo tar xz --one-top-level=/opt/wireguard-ui/
# sudo cp $PATHINSTANCE/wireguard/wgwebui/wg-reload.{service,path} -t /usr/lib/systemd/system
# sudo cp $PATHINSTANCE/wireguard/wgwebui/wireguard-ui.service -t /usr/lib/systemd/system
# sudo cp $PATHINSTANCE/wireguard/wgwebui/wgiptables.sh /opt/wireguard-ui/wgiptablesrules
# sudo systemctl daemon-reload
# sudo systemctl enable --now wg-reload wireguard-ui wg-quick@wg0

# Then open in browser ip_server:5000
# The  default username and password are admin. Please change it to secure your setup.
# Specify in server settings PostUp and PostDown script:
# PostUp:   "/opt/wireguard-ui/wgiptablesrules up"
# PostDown: "/opt/wireguard-ui/wgiptablesrules down"
# Save server settings and check connection for some user 
# systemctl status --no-pager -l wg-reload wireguard-ui wg-quick@wg0


## Under construction, traffic logger:
# mkdir -p var && cd var
# # Please save all *.conf files in instance/wireguard/var directory
#
# # For wgstat for TG script without sudo
# echo "%wheel ALL=(ALL:ALL) NOPASSWD:/usr/bin/wg show wg0" | sudo tee /etc/sudoers.d/wgstatus
# sudo chmod 440 /etc/sudoers.d/wgstatus
# sudo visudo -c
#
# # Install wgstat service
# #IMPORTANT: Only for one partition systems. Use cp instead ln below:
# sudo ln -sf $PATHINSTANCE/wireguard/stat/wgstat /usr/bin/wgstat
#
# sudo cp $PATHINSTANCE/wireguard/stat/wgstat.{service,timer} -t /etc/systemd/system
# sudo systemctl daemon-reload
# sudo systemctl enable --now wgstat.timer
