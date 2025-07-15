#!/usr/bin/env bash
# Install packages:
# paru -Syu --needed lsd mc reflector expac fzf bash-completion etc-update less jq bat

# https://wiki.archlinux.org/title/Bash#Aliases
## ALIASES MANAGEMENT
alias baupdate=". ~/.bash_aliases"
alias brupdate=". ~/.bashrc"

# https://wiki.archlinux.org/title/Systemd#Using_units
## SYSTEMD MANAGEMENT
Sstatus() { systemctl --user status --no-pager -l "$1" 2>/dev/null || systemctl status --no-pager -l "$1"; }
Systemctl() {
    A="$1"
    shift
    (systemctl --user "$A" "$@" 2>/dev/null || sudo systemctl "$A" "$@") && wait3sec "Success! Wait 3 sec"
    Sstatus "${!#}"
}
Sstart() { Systemctl start "$@"; }
Sstop() { Systemctl stop "$@"; }
Srestart() { Systemctl restart "$@"; }
Sdisable() { Systemctl disable "$@"; }

Senable() { sudo systemctl enable "$@"; }
alias Stimers="systemctl list-timers --all"
alias Slists="systemctl list-units --type=service --all --no-pager"

## TUNING PROGRAMS
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias grep="grep --color=auto"
alias less="bat -p"
alias cat="bat -pp"

## SHORTS
alias openports="sudo ss -ntulp"
alias x="exit"
alias gethash="head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n'"
alias boottime="systemd-analyze && systemd-analyze blame --no-pager"

## SHORTS: EXTERNAL PROGRAMS
alias ls="lsd --group-directories-first -F --icon-theme unicode"
alias 0x0="curl -4 -F file=@- https://0x0.st"
alias tb="(exec 3<>/dev/tcp/termbin.com/9999; cat >&3; cat <&3; exec 3<&-)"
alias bugspaces="grep -RnE ' $' 2>/dev/null"
# https://wiki.archlinux.org/title/Reflector
alias umirror="sudo reflector --verbose -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist"

## OTHER FUNCTIONS
backup() { cp "$1"{,.backup}; }
sbackup() { sudo /usr/bin/cp -iv "$1"{,.backup}; }
cd() { builtin cd "$@" && ls; }
wait3sec() {
    echo -n "$1"
    for i in . . .; do
        echo -n $i
        sleep 1
    done
    echo
}
line() {
    l=$1"p"
    shift
    sed -n "$l" "$@"
}

## PARU MANAGEMENT
# https://wiki.archlinux.org/title/Fzf#Pacman
Install() {
    case "$#" in
    0)
        echo "Usage: Install <keyword or package(s)> <only>"
        ;;
    1)
        mapfile -t np < <(paru -Ssq "$1" | sort -u | fzf -q "$1" -i -m --reverse --preview 'paru -Sii {1}' --preview-window right:60%:wrap)
        [ -n "${np[*]}" ] && paru -S --needed "${np[@]}"
        ;;
    2)
        [ "$2" = "only" ] && np=("$1") || np=("$@")
        paru -S --needed "${np[@]}"
        ;;
    *)
        paru -S --needed "$@"
        ;;
    esac
}
# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Packages_and_dependencies
Purge() {
    if [ "$#" -eq 0 ]; then
        mapfile -t np < <(comm -23 <((
            pacman -Qqen
            pacman -Qqm
        ) | sort) <((
            expac -l '\n' '%E' base-devel
            expac -l '\n' '%E' base
        ) | sort -u) | sort -u | fzf -i -m --reverse --preview 'paru -Qii {1}' --preview-window right:80%:wrap)
        [ -n "${np[*]}" ] && paru -Rsc "${np[@]}"
    else
        paru -Rsc "$@"
    fi
}
alias Update="paru -Su"
alias Upgrade="paru -Syu"
alias Ccache="paru -Sc"

#SYSTEM MAINTAINING
getnews() {
    # Required by block
    max=$(pacman -Qqu | wc -L)
    if [ "$max" -gt 0 ]; then
        echo -e '\033[0;34m:: \033[0m\033[1mRequired by: \033[0m'
        for pkg in $(pacman -Qqu); do
            printf "%*s:%s\n" "$max" "$pkg" "$(pacman -Qi "$pkg" | grep Req | sed -e 's/Required By     : //g')" | column -c80 -s: -t -W2
        done
    fi
    # Mirror block
    mirror=$(grep -m1 '^[^#]*Server.*=' /etc/pacman.d/mirrorlist | cut -d'/' -f3)
    echo -ne '\033[0;34m:: \033[0m\033[1mMirror:'
    echo -n " $mirror"
    echo -e '\033[0m'
    # Arch news block
    NEWS=$HOME/.cache/archlinux.news
    [ -r "$NEWS" ] || touch "$NEWS"
    rss_url="https://archlinux.org/feeds/news/"
    last_modified=$(curl -sIm3 "$rss_url" | grep -oP "^last-modified: \K[0-9A-Za-z,: ]+")
    if [ -n "$last_modified" ] && ! grep -q "$last_modified" "$NEWS"; then
        latestnews=$(curl -sm3 "$rss_url" | grep -Eo "<lastBuildDate>.*</title>" | sed -e 's/<[^>]*>/ /g;s/+0000  /GMT /g')
        [ -n "$latestnews" ] && (
            echo "$latestnews" >"$NEWS"
            echo -e '\033[0;34m:: \033[0m\033[1mLatest news...\033[0m'
            echo "   $latestnews"
        )
    fi
    # Working with updates
    paru -Syu
}
# https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#.pacnew
alias whatsnew="find /etc -name *.pacnew 2>/dev/null | sed 's/.pacnew//' | fzf --reverse --preview 'diff -y --suppress-common-lines {1} {1}.pacnew' --preview-window right:78%:wrap | xargs -ro sudo etc-update"

## INSTANCE SCRIPTS ##
# PATHINSTANCE SHOULD BE SET IN /etc/profile/instance.sh
if [ -n "$PATHINSTANCE" ]; then
    INSTANCESCRIPTWAY="$PATHINSTANCE/scripts"
    alias ins='cd $PATHINSTANCE'
    alias sc='echo -e "Y\nY" | $INSTANCESCRIPTWAY/cleansystem.sh'
    alias packages='$INSTANCESCRIPTWAY/packages.sh'
    alias age='$INSTANCESCRIPTWAY/age.sh'
    alias ustat='watch -n 10 $INSTANCESCRIPTWAY/serverstatus.sh'
    alias topmem='$INSTANCESCRIPTWAY/topmem.sh'
    alias aurupd='$INSTANCESCRIPTWAY/aurupdates.sh'

    if [ "$(mount | grep -o ' / type btrfs')" != "" ]; then
        alias uisorescue='$INSTANCESCRIPTWAY/uisorescue.sh'
    else
        alias uisorescue="echo 'This alias works with btrfs partitions only'"
    fi

    ## SENSITIVE DATAS: LOGINS, ADDRESSES ETC.
    if [ -f "$INSTANCESCRIPTWAY/sensitive.sh" ]; then
        # shellcheck source=/dev/null
        source "$INSTANCESCRIPTWAY/sensitive.sh"
    fi

    # FOR DEVTOOLS, SET e.g.:
    # checkcustomrepository=yes
    # CONF=/usr/share/devtools/pacman.conf.d/extra.conf
    # repositoryname=myrepo
    # server=http://mydomain.ip or file:///home/custompkgs
    # IN sensitive.sh file above
    # https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot
    if [ -n "$checkcustomrepository" ]; then
        pkgctl() {
            if [ -n "$checkcustomrepository" ] && ! grep -q "${repositoryname:?}" "${CONF:?}"; then
                echo "Please update devtools config file and add custom repository by running: add_custom_repository"
            else
                /usr/bin/pkgctl "$@"
            fi
        }
        add_custom_repository() { printf "\n[%s]\nSigLevel = Never\nServer = %s/\$repo/os/\$arch\n" "${repositoryname:?}" "${server:?}" | sudo tee -a "${CONF:?}"; }
    fi
fi
