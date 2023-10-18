#Wireguard module of Instance project

# Deprecated because of wireguard-ui package in AUR
# https://github.com/angristan/wireguard-install
# curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
# chmod +x wireguard-install.sh
# sudo ./wireguard-install.sh
# sudo systemctl stop wg-quick@wg0



## Under construction, traffic logger:
#source /etc/instance.conf
#cd $PATHINSTANCE/wireguard
#mkdir -p var && cd var
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
