PS1='\n\[\033[00;31m\]\h\[\033[00;37m\]:\[\033[00;34m\]\w\[\033[00m\] $ '
if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
fi
complete -cf sudo
if [ -n "$SSH_CLIENT" ]; then
        red='\033[0;31m'
        nc='\033[0m'
        yellow='\033[1;33m'
        green='\033[0;32m'
		uptime
        echo    
        [ `pacman -Qu | grep -v "\[ignored\]" | wc -l` -ne 0 ] && printf "${yellow}Available updates:\n$(cat /var/log/updpackages.log)${nc}\n" || printf "${green}System is up-to-date${nc}\n"
        echo $(~/instance/scripts/systemage.sh)
		[ `systemctl list-units --failed | grep "listed" | cut -d" " -f1` -ne 0 ] && printf "${red}systemctl list-units --failed${nc}\n"
       	echo
        [ `who | grep pts | wc -l` -ne 1 ] && printf "${yellow}Login warning:\n$(who)${nc}\n" 
fi

#https://github.com/linuxdabbler/personal-dot-files/blob/master/config/bashrc

## don't duplicate lines in history file
export HISTCONTROL=ignoredups:erasedups

## for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

## check the window size after each command and update values for columns
shopt -s checkwinsize

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
