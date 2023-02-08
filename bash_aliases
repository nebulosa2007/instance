# Program packages:
# pikaur -Syu --needed lsd mc reflector expac fzf
# READ FIRST about snaplist alias below

#ALIASES MANAGEMENT
alias baupdate=". ~/.bash_aliases"
alias bpupdate=". ~/.bash_profile"
alias brupdate=". ~/.bashrc"

#SYSTEMD MANAGEMENT
alias Sstart="sudo systemctl start"
alias Sstop="sudo systemctl stop"
alias Senable="sudo systemctl enable"
alias Sdisable="sudo systemctl disable"
alias Sstatus="sudo systemctl status"
alias Srestart="sudo systemctl restart"
alias Stimers="sudo systemctl list-timers --all"
alias Slists="systemctl list-units --type=service --all"

#TUNING PROGRAMS
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias grep="grep --color=auto"

#SHORTS
alias openports="sudo ss -ntulp"
alias x="exit"
alias gethash="tr -dc 'a-z0-9' < /dev/urandom | dd bs=1 count=32 2>/dev/null && echo"
alias boottime="systemd-analyze && systemd-analyze blame --no-pager"

#SHORTS: EXTERNAL PROGRAMS
alias ls="lsd --group-directories-first"
alias 0x0="curl -F file=@- https://0x0.st"
alias mc="EDITOR=micro mc"
alias umirror="sudo reflector --verbose -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist"
source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash


#OTHER FUNCTIONS
backup () { cp "$1"{,.backup};}
sbackup () { sudo cp "$1"{,.backup};}
cd() { builtin cd "$@" && command lsd --group-directories-first --color=auto -F; }

#PIKAUR MANAGEMENT
Install () { pikaur -Sslq $@ | sort -u | grep -v ^lib32 | fzf -i -m --reverse --preview 'pikaur -Si {1}' --preview-window right:60%:wrap | xargs -ro pikaur -S --needed; }
Purge	() { (pikaur -Qqn; pacman -Qqm)	| fzf -q $@ -i -m --reverse --preview 'pikaur -Si {1}' --preview-window right:60%:wrap | xargs -ro pikaur -Rsc;		}
Clean	() { comm -23 <( (pacman -Qqen; pacman -Qqm) | sort) <({ pacman -Qqg base-devel; expac -l '\n' '%E' base; } | sort -u) | fzf -m --reverse --preview 'pikaur -Si {1}' --preview-window right:60%:wrap | xargs -ro pikaur -Rsc; }
alias Update="pikaur -Su"
alias Upgrade="pikaur -Syu"
alias Ccache="pikaur -Sc"

#SYSTEM MAINTAINING
alias getnews="echo; echo -ne '\033[0;34m:: \033[0m\033[1mMirror: '; grep -m1 Server /etc/pacman.d/mirrorlist | cut  -d'/' -f3; echo -e '\033[0m'; pikaur -Syu"
alias whatsnew="find /etc 2>/dev/null | grep pacnew"
pd () { sudo diff -y --suppress-common-lines "$1"{,.pacnew};}

## INSTANCE SCRIPTS ##
WAY="$HOME/instance/scripts"
alias sc='echo -e "Y\nY" | $WAY/cleansystem.sh'
alias packages="$WAY/allpacks.sh"
alias age="$WAY/systemage.sh"
alias ustat="watch -n 10 $WAY/serverstatus.sh"
alias topmem="$WAY/topmem.sh"

if [ "$(mount | grep -o ' / type btrfs')" != "" ]; then 
	SNAPWAY="$HOME/instance/snapshots"
	# For proper rights snaplist alias do:
	# echo "%wheel ALL=(ALL:ALL) NOPASSWD:/usr/bin/btrfs subvolume list /" | sudo tee /etc/sudoers.d/btrfslist
	alias snaplist="sudo /usr/bin/btrfs subvolume list / | cut -d' ' -f9 | grep -Ev '^@' | fzf --reverse --preview '$SNAPWAY/snaplist.sh {1}' --preview-window right:70%:wrap"
	alias urescue="$SNAPWAY/make_rescue_iso_updater.sh"
else
	alias snaplist="echo 'This alias works with btrfs partitions only'"
	alias urescue="echo 'This alias works with btrfs partitions only'"
fi

## SENSITIVE DATAS: LOGINS, ADDRESSES ETC.
if [ -f "$WAY/sensitive.sh" ]; then
	source "$WAY/sensitive.sh"
fi

