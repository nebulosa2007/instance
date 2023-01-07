# Tuning network

## /etc/systemd/network/20-ethernet.network
## Name=en*
## Name=eth*
## 
## [Network]
## Gateway=......
## Address=....../24
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sudo systemctl restart systemd-networkd
ip a

passwd

lsblk

# throught ssh connection
# BIOS machine: dos, primary, bootable
cfdisk /dev/vda

mkfs.ext4 /dev/vda1
tune2fs -m1 -r1 /dev/vda1

mount -o defaults,noatime,commit=60 /dev/vda1 /mnt
lsblk
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

pacstrap /mnt base base-devel linux grub e2fsprogs

cp -f /etc/systemd/network/20-ethernet.network /mnt/etc/systemd/network/20-ethernet.network
cp -f /etc/resolv.conf /mnt/etc/resolv.conf
sudo systemctl enable systemd-networkd


#generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

#start the party!
arch-chroot /mnt


##INSIDE CHROOT
cat /etc/fstab

#for default preset only in /etc/mkinitcpio.d/linux.preset :  PRESETS=('default')
sed -i "s/PRESETS=('default' 'fallback')/PRESETS=('default')/" /etc/mkinitcpio.d/linux.preset
mkinitcpio -P
rm /boot/initramfs-linux-fallback.img
#install GRUB on BIOS
grub-install --target=i386-pc --recheck /dev/vda
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
sed -i 's/#NoExtract   =/NoExtract   = usr\/share\/man\/* usr\/share\/help\/* usr\/share\/locale\/* !usr\/share\/locale\/en_US* !usr\/share\/locale\/locale.alias/' /etc/pacman.conf


#set variables
M=vpsrus
U=ds

#Uncomment en_US.UTF-8 only and generate locales
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen
#Set locales for other GUI programs
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

#Set machine name. "virtarch" in my case.
echo $M >> /etc/hostname
printf "127.0.0.1 localhost\n::1       localhost\n127.0.0.1 $M.localhost $M\n" >> /etc/hosts
cat /etc/hostname /etc/hosts

#Set root password. CHANGE FOR YOUR OWN
echo root:password | chpasswd

#Add user login in system
useradd -mG wheel $U
passwd $U
#Sudo activating
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

pacman -S openssh
systemctl enable sshd

systemctl enable fstrim.timer

# install vnstat
pacman -S vnstat
systemctl enable vnstat



exit&&cd&&umount -R /mnt
reboot

# Login trought ssh, then:

# Tuning ssh
# Add .ssh/id_rsa.pub into .ssh/authorized_keys
sudo sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

#Tune date and time. 'timedatectl list-timezones' for other variants
sudo timedatectl set-timezone Europe/Moscow
sudo timedatectl set-ntp true
sudo timedatectl status

#reflector
sudo pacman -S reflector
sudo reflector --verbose -l 3 -p https --sort rate --save /etc/pacman.d/mirrorlist
sudo systemctl enable reflector.timer

#pikaur - AUR helper, smallest one
sudo pacman -S --needed git
git clone https://aur.archlinux.org/pikaur.git
cd pikaur && makepkg -fsri && cd .. && rm -rf pikaur

#Install zramd
pikaur -S zramd
sudo systemctl enable --now zramd

# Install programs to instance scripts
pikaur -Syu --needed iproute2 lsd micro mc reflector htop btop expac neofetch ranger tmux

# instance project installing
cd
git clone git@github.com:nebulosa2007/instance.git
ln -sf /home/$(whoami)/instance/bashrc .bashrc
ln -s /home/$(whoami)/instance/bash_aliases .bash_aliases
sudo ln -s /home/$(whoami)/instance/etc/tmux.conf /etc/tmux.conf
sudo cp /home/$(whoami)/instance/etc/99-sysctl.conf /etc/sysctl.d/99-sysctl.conf
sudo sysctl --system

# install update timer
cd instance/update
sudo ln -s /home/$(whoami)/instance/update/updpkgs.sh /usr/bin/updpkgs
sudo ln -s /home/$(whoami)/instance/update/update.service /lib/systemd/system/update.service
sudo ln -s /home/$(whoami)/instance/update/update.timer /lib/systemd/system/update.timer
sudo systemctl daemon-reload
sudo systemctl enable --now update.timer

# install localepurge
pikaur -Syu --needed localepurge
sudo ln -sf /home/$(whoami)/instance/etc/locale.nopurge /etc/locale.nopurge


# install wireguard
cd && mkdir wireguard && cd wireguard
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh 
sudo ./wireguard-install.sh 