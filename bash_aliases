# Program packages:
# pikaur -Syu --needed lsd mc reflector expac

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
alias ls=lsd
alias 0x0="curl -F file=@- https://0x0.st"
alias mc="EDITOR=micro mc"
alias umirror="sudo reflector --verbose -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist"

#OTHER FUNCTIONS
backup () { cp "$1"{,.backup};}
sbackup () { sudo cp "$1"{,.backup};}

#PIKAUR MANAGEMENT
Install () { pikaur -S --needed $@ || pikaur $1; }
alias Update="pikaur -Su"
alias Upgrade="pikaur -Syu"
alias Search="pikaur -Ss"
alias Purge="pikaur -Rsc"
alias Clean="pikaur -Sc"

#SYSTEM MAINTAINING
alias topmem="ps -e -orss=,args= |awk '{print \$1 \" \" \$2 }'| awk '{tot[\$2]+=\$1;count[\$2]++} END {for (i in tot) {print tot[i],i,count[i]}}' | sort -n | tail -n 15 | sort -nr | awk '{ hr=\$1/1024; printf(\"%13.2fM\", hr); print \"\t\" \$2 }'; echo; free -m | awk '/Mem/{print(\$1\"\t\"\$3\"M\")}'"
alias topswp="cat /proc/*/status | grep -E 'VmSwap:|Name:' | grep -B1 'VmSwap' | cut -d':' -f2 | grep -v -- '--' | grep -o -E '[a-zA-Z0-9]+.*$' | cut -d' ' -f1 | xargs -n2 echo | sort -hrk2 | awk '{ hr=\$2/1024; if (hr>0) printf(\"%13.2fM\", hr); if (hr>0) print \"\t\" \$1}'; echo; free -m | awk '/Swap/{print(\$1\"\t\"\$3\"M\")}'"

alias getnews="echo; echo -ne '\033[0;34m:: \033[0m\033[1mMirror: '; grep -m1 Server /etc/pacman.d/mirrorlist | cut  -d'/' -f3; echo -e '\033[0m'; pikaur -Syu"
alias whatsnew="find /etc 2>/dev/null | grep pacnew"
pd () { sudo diff -y --suppress-common-lines "$1"{,.pacnew};}


## INSTANCE SCRIPTS ##
WAY="$HOME/instance/scripts"

alias sc='echo -e "Y\nY" | $WAY/cleansystem.sh'
alias packages="$WAY/allpacks.sh"
alias age="$WAY/systemage.sh"
alias ustat="watch -n 10 $WAY/serverstatus.sh"

## SENSITIVE DATAS: LOGINS, ADDRESSES ETC.
if [ -f "$WAY/sensitive.sh" ]; then
	source "$WAY/sensitive.sh"
fi
