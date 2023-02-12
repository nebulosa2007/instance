#!/bin/bash

# pikaur -Syu --needed expac

echo -e  "\033[1mFrom repository:\033[0m"
expac -H M "%011m\t%-20n\t%10d" $(comm -23 <( pacman -Qqen | sort) <({ pacman -Qqg base-devel; expac -l '\n' '%E' base; } | sort -u)) 
[ -n "$(pacman -Qm)"  ] && ( echo -e "\n\033[1mFrom AUR:\033[0m"; expac -H M "%011m\t%-20n\t%10d" $(pacman -Qqm) )
