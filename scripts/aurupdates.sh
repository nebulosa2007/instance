#!/bin/env bash

folder=$HOME/.cache/repoctl

function print_help {
    underline=$(tput smul)
    nounderline=$(tput rmul)
    echo "
Check updates for packages installed from AUR. Support local installed packages or repoctl

${underline}Usage${nounderline}: ${0##*/} [OPTIONS] [repoctl]

${underline}Options${nounderline}:
       -h  Print help information
       -u  Print URL source for updates
       -m  Build updates throught makepkg -srf (default) or be added, e.g. '-m rsCc'
       -p  Build updates throught 'pkgctl build' in a clean chroot
       -q  Supress info, show info about updates only
       -c  Clean cache folder after checking

${underline}Modes${nounderline}:
        *  Check installed packages. Default mode
  repoctl  Check packages at you own repository
"
}

function cleanfolder (){
    if [ -n "$clean" ]; then
        [ -z "$lessinfo" ] && echo -e "\nCleaning cache..."
        find "$folder" -delete
    fi
}

function updaterepo (){
    [ ! -d "$folder" ] && mkdir "$folder"

    pushd "$folder" > /dev/null || exit 1
    : > build-order.txt
    repoctl down -ul -o build-order.txt 2>/dev/null
    mapfile -t buildorder < build-order.txt
    popd > /dev/null || exit 1
}

function checkaurgit (){

    if [ "$1" == "repoctl" ]; then
        mapfile -t gitpackages < <(repoctl list | grep "git")
        mapfile -t gitpackageversions < <(repoctl list -v | grep "git" | cut -d " " -f2)
    else
        mapfile -t gitpackages < <(pacman -Qq | grep "\-git$")
        mapfile -t gitpackageversions < <(pacman -Q | grep "\-git " | cut -d " " -f2)
    fi

    [ ! -d "$folder" ] && mkdir "$folder"

    pushd "$folder" > /dev/null || exit 1

    for index in ${!gitpackages[*]}; do
        gitpackage=${gitpackages[$index]}
        gitpackageversion=${gitpackageversions[$index]}

        [ -z "$lessinfo" ] && echo -e "\nChecking package: $gitpackage"

        [ ! -d "$gitpackage" ] && git clone --quiet "https://aur.archlinux.org/$gitpackage.git" 2> /dev/null
        builtin cd "$gitpackage" || exit 2
        mapfile -t giturl < <(grep -Pom1 '(?<=git\+)http.*' .SRCINFO | sed 's|#branch=| -b |')
        # shellcheck disable=SC2068
        [ ! -d "${gitpackage%-git}" ] && git clone --quiet ${giturl[@]} "${gitpackage%-git}" 2> /dev/null

        builtin cd "${gitpackage%-git}" || exit 3
        git pull --quiet

        gitversion=$(
            set -euo pipefail;
            git describe --long --tags --abbrev=7 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g;s/^ver.//;s/^v//' \
         || printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
            )

        if [[ ! "$gitpackageversion" =~ ${gitversion: -6} ]]; then
            echo "$gitpackage ${gitpackageversion%-*} -> $gitversion"
            [ -n "$show_url" ] && [ -z "$lessinfo" ] && grep -Po '(?<=url = ).*' ../.SRCINFO
            updpackages+=("$gitpackage")
        else
            [ -z "$lessinfo" ] && echo "Version ${gitpackageversion%-*} is up to date"
        fi
        builtin cd "$folder" || exit 2
    done
    popd > /dev/null || exit 1
}

function addtopero (){
if [ -x /usr/bin/repoctl ]; then
    #read -n 1 -p "Add package to repository? [Y/n] " -r reply
    #[ "$reply" != "" ] && echo
    #if [ "$reply" = "${reply#[Nn]}" ]; then
        find ! -name '*debug*' -name '*.pkg.tar.zst' -exec repoctl add {} \;
    #fi
fi
}

while getopts ':hupm:qc' option; do
    case "$option" in
         h ) print_help; exit 0;;
         u ) show_url="y";;
         p ) pkgctl="y";;
         m ) mkpgoptions="-$OPTARG";;
         q ) lessinfo="y";;
         c ) clean="y";;
         : ) mkpgoptions="-rfs";;
        \? ) [ -n "$OPTARG" ] && { echo "Option not found, try -h" && exit 1; }
    esac
done
shift $((OPTIND - 1))

if [ "$1" == "repoctl" ] || [ "$mkpgoptions" == "-repoctl" ]; then
    [ -x /usr/bin/repoctl ] && updaterepo && checkaurgit repoctl || echo "Repoctl not installed. Exiting..."
else
    checkaurgit
fi

for package in $(echo "${buildorder[@]}" "${updpackages[@]}" | tr ' ' '\n' | uniq); do
    pushd "$folder/$package" > /dev/null || exit 1
    if [ -n "$mkpgoptions" ] && [ -x /usr/bin/makepkg ]; then
        [ "$mkpgoptions" == "-repoctl" ] && mkpgoptions="-rfs"
        echo -e "\nBuild $package with options $mkpgoptions"
        makepkg "$mkpgoptions" && addtopero && find . -maxdepth 1 -name '*.pkg.tar.zst' -delete
    elif [ -n "$pkgctl" ] && [ -x /usr/bin/pkgctl ]; then
        echo -e "\nBuild $package in a clean chroot"
        pkgctl build && addtopero && find . -maxdepth 1 -name '*.pkg.tar.zst' -delete
    fi
    popd > /dev/null || exit 1
done

cleanfolder
