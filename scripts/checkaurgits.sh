#!/bin/bash

function print_help {
    underline=$(tput smul)
    nounderline=$(tput rmul)
    echo "
Check source version for -git packages installed from AUR. Support local installed packages or repoctl

${underline}Usage${nounderline}: ${0##*/} [OPTIONS] [repoctl]

${underline}Options${nounderline}:
       -h  Print help information
       -u  Print URL source for updates
       -b  Build updates. Default option for makepkg is '-rs' or can be added, e.g. '-b rsCc'
       -q  Supress info, show info about updates only
       -c  Clean cache folder after checking

${underline}Modes${nounderline}:
        *  Check installed packages. Default mode
  repoctl  Check packages at you own repository
"
}


function checkaurgit (){

    if [ "$1" == "repoctl" ]; then
        mapfile -t gitpackages < <(repoctl list | grep "git")
        mapfile -t gitpackageversions < <(repoctl list -v | grep "git" | cut -d " " -f2)
    else
        mapfile -t gitpackages < <(pacman -Qq | grep "\-git$")
        mapfile -t gitpackageversions < <(pacman -Q | grep "\-git " | cut -d " " -f2)
    fi

    gitaurfolder=$HOME/.cache/aurgits
    [ ! -d "$gitaurfolder" ] && mkdir "$gitaurfolder"

    pushd "$gitaurfolder" > /dev/null || exit 1

    for index in ${!gitpackages[*]}; do
        gitpackage=${gitpackages[$index]}
        gitpackageversion=${gitpackageversions[$index]}

        [ -z "$lessinfo" ] && echo -e "\nChecking package: $gitpackage"

        [ ! -d "$gitpackage" ] && git clone --quiet "https://aur.archlinux.org/$gitpackage.git" 2> /dev/null
        builtin cd "$gitpackage" || exit 2
        mapfile -t giturl < <(grep -Po '(?<=git\+)http.*' .SRCINFO | sed 's|#branch=| -b |')
        [ ! -d "${gitpackage%-git}" ] && git clone --quiet ${giturl[*]} "${gitpackage%-git}" 2> /dev/null

        builtin cd "${gitpackage%-git}" || exit 3
        git pull --quiet

        gitversion=$(
            set -euo pipefail;
            git describe --long --tags --abbrev=7 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g;s/^v//' \
         || printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
            )
        if [[ ! "$gitpackageversion" =~ ${gitversion: -6} ]]; then
            echo "$gitpackage ${gitpackageversion%-*} -> $gitversion"
            [ -n "$show_url" ] && [ -z "$lessinfo" ] && grep -Po '(?<=url = ).*' ../.SRCINFO
        else
            [ -z "$lessinfo" ] && echo "Version ${gitpackageversion%-*} is up to date"
        fi
        builtin cd "$gitaurfolder" || exit 2
    done
    if [ -n "$clean" ]; then
        [ -z "$lessinfo" ] && echo -e "\nCleaning cache..."
        find "$gitaurfolder" -delete
    fi
    popd > /dev/null || exit 1
}

while getopts ':hub:qc' option; do
    case "$option" in
         h ) print_help; exit 0;;
         u ) show_url="y";;
         b ) build="y"; mkpgoptions="-$OPTARG";;
         q ) lessinfo="y";;
         c ) clean="y";;
        \? ) [ -n "$OPTARG" ] && { echo "Option not found, try -h" && exit 1; }
    esac
done
shift $((OPTIND - 1))

if [ "$1" == "repoctl" ]; then
    [ -x /usr/bin/repoctl ] && checkaurgit repoctl || echo "Repoctl not installed. Exiting..."
else
    checkaurgit
fi

if [ -n "$build" ]; then
    [ -z "$mkpgoptions" ] && mkpgoptions="-rs"
    echo -n "\nBuild with options $mkpgoptions"
fi
