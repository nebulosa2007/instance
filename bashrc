# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\n\[\033[00;31m\]\h\[\033[00;37m\]:\[\033[00;34m\]\w\[\033[00m\] $ '
	if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
	fi
complete -cf sudo

red='\033[0;31m'
nc='\033[0m'
yellow='\033[1;33m'

echo

[ `pacman -Qu | wc -l` -ne 0 ] && ( printf "${red}Available updates:\n"; cat /var/log/updpackages.log; printf "${nc}\n" ) || echo "System is up-to-date"

printf "${yellow}" ; ~/instance/scripts/systemage.sh ; printf "${nc}\n"
