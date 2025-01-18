# Program packages:
# paru -Syu --needed lsd mc reflector expac fzf bash-completion etc-update less jq

# https://wiki.archlinux.org/title/Bash#Aliases
## ALIASES MANAGEMENT
alias baupdate=". ~/.bash_aliases"
alias brupdate=". ~/.bashrc"

# https://wiki.archlinux.org/title/Systemd#Using_units
## SYSTEMD MANAGEMENT
Sstatus   () { systemctl --user status --no-pager -l "$1" 2>/dev/null || systemctl status --no-pager -l "$1"; }
Systemctl () { A="$1"; shift; (systemctl --user "$A" "$@" 2>/dev/null || sudo systemctl "$A" "$@" ) && wait3sec "Success! Wait 3 sec"; Sstatus "${!#}"; }
Sstart    () { Systemctl start "$@"; }
Sstop     () { Systemctl stop "$@"; }
Srestart  () { Systemctl restart "$@"; }
Sdisable  () { Systemctl disable "$@"; }

Senable   () { sudo systemctl enable "$@"; }
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
alias ls="lsd --group-directories-first -F --icon-theme unicode"
alias 0x0="curl -4 -F file=@- https://0x0.st"
alias bugspaces="grep -RnE ' $' 2>/dev/null"
# https://wiki.archlinux.org/title/Reflector
alias umirror="sudo reflector --verbose -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist"

## OTHER FUNCTIONS
backup  () { cp "$1"{,.backup}; }
sbackup () { sudo cp "$1"{,.backup}; }
cd      () { builtin cd "$@" && ls; }
wait3sec() { echo -n "$1"; for i in . . . ; do echo -n $i; sleep 1; done; echo; }
line    () { l=$1"p"; shift; sed -n "$l" "$@"; }

## PARU MANAGEMENT
# https://wiki.archlinux.org/title/Fzf#Pacman
Install () { [ "$#" -eq 0 ] && echo "Usage: Install <keyword or package(s)> <only>" && return; [ $# -eq 2 ] && [ $2 == "only" ] && { paru -S --needed $1; return; }; if [ $# -eq 1 ]; then np=$(paru -Ssq $1 | sort -u | fzf -q $1 -i -m --reverse --preview 'paru -Sii {1}' --preview-window right:60%:wrap); [ -n "$np" ] && paru -S --needed $np; else paru -S --needed $@; fi; }
# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Packages_and_dependencies
Purge () { if [ "$#" -eq 0 ]; then np=$(comm -23 <((pacman -Qqen; pacman -Qqm)| sort) <((expac -l '\n' '%E' base-devel; expac -l '\n' '%E' base) | sort -u) | sort -u | fzf -i -m --reverse --preview 'paru -Qii {1}' --preview-window right:80%:wrap); [ -n "$np" ] && paru -Rsc $np; else paru -Rsc $@; fi; }
alias Update="paru -Su"
alias Upgrade="paru -Syu"
alias Ccache="paru -Sc"

#SYSTEM MAINTAINING
getnews () {
    # Required by block
    max=$(pacman -Qqu | wc -L)
    if [ "$max" -gt 0 ]
    then
        echo -e '\033[0;34m:: \033[0m\033[1mRequired by: \033[0m'
        for pkg in $(pacman -Qqu)
        do
            printf "%*s:%s\n" "$max" "$pkg" "$(pacman -Qi "$pkg" | grep Req | sed -e 's/Required By     : //g')" | column -c80 -s: -t -W2
        done
    fi
    # Mirror block
    mirror=$(grep -m1 '^[^#]*Server.*=' /etc/pacman.d/mirrorlist | cut  -d'/' -f3)
    echo -ne '\033[0;34m:: \033[0m\033[1mMirror:'; echo -n " $mirror"; echo -e '\033[0m';
    # Arch news block
    NEWS=$HOME/.cache/archlinux.news; [ -z "$NEWS" ] || touch "$NEWS"
    latestnews=$(curl -s https://archlinux.org/feeds/news/ | grep -Eo "<lastBuildDate>.*</title>" | sed -e 's/<[^>]*>/ /g;s/+0000  //g')
    if [ "$(cat "$NEWS")" != "$latestnews" ]
    then
        echo "$latestnews" > "$NEWS"
        echo -e '\033[0;34m:: \033[0m\033[1mLatest news...\033[0m'; echo "$latestnews"
    fi
    # Working with updates
    paru -Syu
}
# https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#.pacnew
alias whatsnew="find /etc -name *.pacnew 2>/dev/null | sed 's/.pacnew//' | fzf --reverse --preview 'diff -y --suppress-common-lines {1} {1}.pacnew' --preview-window right:78%:wrap | xargs -ro sudo etc-update"


## INSTANCE SCRIPTS ##
if [ -n "$PATHINSTANCE" ]; then
     INSTANCESCRIPTWAY="$PATHINSTANCE/scripts"
     alias ins="cd $PATHINSTANCE"
     alias sc='echo -e "Y\nY" | $INSTANCESCRIPTWAY/cleansystem.sh'
     alias packages="$INSTANCESCRIPTWAY/packages.sh"
     alias age="$INSTANCESCRIPTWAY/age.sh"
     alias ustat="watch -n 10 $INSTANCESCRIPTWAY/serverstatus.sh"
     alias topmem="$INSTANCESCRIPTWAY/topmem.sh"
     alias aurupd="$INSTANCESCRIPTWAY/aurupdates.sh"

     if [ "$(mount | grep -o ' / type btrfs')" != "" ]; then
          alias snapctl="yabsnap list-json | jq -r '.trigger+\" \"+.file.timestamp' | fzf -m --reverse --preview '$INSTANCESCRIPTWAY/snaplist.sh {2}'  --preview-window right:70%:wrap | xargs -I{} echo {} | cut -d' ' -f2 | xargs -I{} sudo yabsnap delete {}"
          alias uisorescue="$INSTANCESCRIPTWAY/uisorescue.sh"
     else
          alias {snapctl,uisorescue}="echo 'This alias works with btrfs partitions only'"
     fi

     ## SENSITIVE DATAS: LOGINS, ADDRESSES ETC.
     if [ -f "$INSTANCESCRIPTWAY/sensitive.sh" ]; then
          source "$INSTANCESCRIPTWAY/sensitive.sh"
     fi
fi
