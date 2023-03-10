#!/bin/bash

# https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Packages_and_dependencies
## sudo pacman -Syu --needed expac

echo -e  "\033[1mFrom repository:\033[0m"
expac -H M "%011m\t%-20n\t%10d" $(comm -23 <(pacman -Qqen | sort) <((expac -l '\n' '%E' base-devel; expac -l '\n' '%E' base) | sort -u)) 
[ -n "$(pacman -Qm)"  ] && ( echo -e "\n\033[1mFrom AUR:\033[0m"; expac -H M "%011m\t%-20n\t%10d" $(pacman -Qqm) )
