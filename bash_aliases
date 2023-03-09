# Program packages:
# pikaur -Syu --needed lsd mc reflector expac fzf bash-completion etc-update
# READ FIRST about snaplist alias below

# https://wiki.archlinux.org/title/Bash#Aliases
## ALIASES MANAGEMENT
alias baupdate=". ~/.bash_aliases"
alias brupdate=". ~/.bashrc"

# https://wiki.archlinux.org/title/Systemd#Using_units
## SYSTEMD MANAGEMENT
Sstart   () { sudo systemctl start   "$1" && echo "Success! Waiting 3 sec..." && sleep 3 && sudo systemctl status "$1" --no-pager -l; }
Sstop    () { sudo systemctl stop    "$1" && echo "Success! Waiting 3 sec..." && sleep 3 && sudo systemctl status "$1" --no-pager -l; }
Srestart () { sudo systemctl restart "$1" && echo "Success! Waiting 3 sec..." && sleep 3 && sudo systemctl status "$1" --no-pager -l; }
alias Senable="sudo systemctl enable"
alias Sdisable="sudo systemctl disable"
alias Sstatus="sudo systemctl status"
alias Stimers="systemctl list-timers --all"
alias Slists="systemctl list-units --type=service --all --no-pager"

## TUNING PROGRAMS
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias grep="grep --color=auto"

## SHORTS
alias openports="sudo ss -ntulp"
alias x="exit"
alias gethash="tr -dc 'a-z0-9' < /dev/urandom | dd bs=1 count=32 2>/dev/null && echo"
alias boottime="systemd-analyze && systemd-analyze blame --no-pager"

## SHORTS: EXTERNAL PROGRAMS
alias ls="lsd --group-directories-first -F"
alias 0x0="curl -F file=@- https://0x0.st"
alias mc="EDITOR=micro mc"
# https://wiki.archlinux.org/title/Reflector
alias umirror="sudo reflector --verbose -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist"

## OTHER FUNCTIONS
backup  () { cp "$1"{,.backup}; }
sbackup () { sudo cp "$1"{,.backup}; }
cd      () { builtin cd "$@" && ls; }

## PIKAUR MANAGEMENT
# https://wiki.archlinux.org/title/Fzf#Pacman
Install () { [ "$#" -eq 0 ] && echo "Usage: Install <keyword or package(s)>" || ([ "$#" -eq 1 ] && (pikaur -Sslq $1 | sort -u | fzf -q $1 -i -m --reverse --preview 'pikaur -Sii {1}' --preview-window right:60%:wrap | xargs -ro pikaur -S --needed) || pikaur -S --needed $@); }
# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Packages_and_dependencies
Purge	() { [ "$#" -eq 0 ] && (comm -23 <((pacman -Qqen; pacman -Qqm)| sort) <((expac -l '\n' '%E' base-devel; expac -l '\n' '%E' base) | sort -u) | sort -u | fzf -i -m --reverse --preview 'pikaur -Sii {1}' --preview-window right:80%:wrap | xargs -ro pikaur -Rsc) || pikaur -Rsc $@; }
alias Update="pikaur -Su"
alias Upgrade="pikaur -Syu"
alias Ccache="pikaur -Sc"

#SYSTEM MAINTAINING
alias getnews="echo; echo -ne '\033[0;34m:: \033[0m\033[1mMirror: '; grep -m1 Server /etc/pacman.d/mirrorlist | cut  -d'/' -f3; echo -e '\033[0m'; pikaur -Syu"
# https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#.pacnew
alias whatsnew="find /etc -name *.pacnew 2>/dev/null | sed 's/.pacnew//' | fzf --reverse --preview 'diff -y --suppress-common-lines {1} {1}.pacnew' --preview-window right:78%:wrap | xargs -ro sudo etc-update"

## INSTANCE SCRIPTS ##
INSTANCESCRIPTWAY="$HOME/instance/scripts"
alias sc='echo -e "Y\nY" | $INSTANCESCRIPTWAY/cleansystem.sh'
alias packages="$INSTANCESCRIPTWAY/packages.sh"
alias age="$INSTANCESCRIPTWAY/age.sh"
alias ustat="watch -n 10 $INSTANCESCRIPTWAY/serverstatus.sh"
alias topmem="$INSTANCESCRIPTWAY/topmem.sh"

if [ "$(mount | grep -o ' / type btrfs')" != "" ]; then 
	SNAPWAY="$HOME/instance/snapshots"
	# https://wiki.archlinux.org/title/Sudo#Configure_sudo_using_drop-in_files_in_/etc/sudoers.d
	## For proper rights snaplist alias, do:
	## echo "%wheel ALL=(ALL:ALL) NOPASSWD:/usr/bin/btrfs subvolume list /" | sudo tee /etc/sudoers.d/btrfslist && sudo chmod 440 /etc/sudoers.d/btrfslist && sudo visudo -c
	alias snaplist="sudo /usr/bin/btrfs subvolume list / | cut -d' ' -f9 | grep -Ev '^@' | fzf --reverse --preview '$SNAPWAY/snaplist.sh {1}' --preview-window right:70%:wrap"
	alias urescue="$SNAPWAY/make_rescue_iso_updater.sh"
	alias purgesnap="$SNAPWAY/purgesnap.sh"
else
	alias {snaplist,urescue,purgesnap}="echo 'This alias works with btrfs partitions only'"
fi

## SENSITIVE DATAS: LOGINS, ADDRESSES ETC.
if [ -f "$INSTANCESCRIPTWAY/sensitive.sh" ]; then
	source "$INSTANCESCRIPTWAY/sensitive.sh"
fi

