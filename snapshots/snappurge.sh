#!/bin/bash

if [ "$(mount | grep -o ' / type btrfs')" != "" ]; then 
	SNAPWAY="$HOME/instance/snapshots"
	sudo mount /dev/sda1 /mnt && cd /mnt && sudo /usr/bin/btrfs subvolume list / | cut -d' ' -f9 | grep -Ev '^@' | fzf -m --reverse --preview "$SNAPWAY/snaplist.sh {1}" --preview-window right:70%:wrap | xargs sudo btrfs subvolume delete
	cd / && sudo umount /mnt
else
	echo "This scipts works only with btrfs snapshots. Nothing to do..."
fi
