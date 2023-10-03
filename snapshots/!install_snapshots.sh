#Snapshots module of Instance project

source /etc/instance.conf

#IMPORTANT: Only for one partition systems. Use cp instead ln below:
sudo ln -sf $PATHINSTANCE/snapshots/mksnaproot.sh /usr/bin/mksnaproot

sudo mkdir -p /etc/pacman.d/hooks
sudo cp $PATHINSTANCE/snapshots/01-btrfs-autosnap.hook /etc/pacman.d/hooks/01-btrfs-autosnap.hook

#Package cache cleaning for minimizing size of snapshots
sudo rm -f /var/cache/pacman/pkg/*
sudo sed -i 's/#CacheDir    = \/var\/cache\/pacman\/pkg\//CacheDir     = \/tmp\//' /etc/pacman.conf
