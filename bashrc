PS1='\n\[\033[00;31m\]\h\[\033[00;37m\]:\[\033[00;34m\]\w\[\033[00m\] $ '
if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
fi
complete -cf sudo
if [ -n "$SSH_CLIENT" ]; then
        red='\033[0;31m'
        nc='\033[0m'
        yellow='\033[1;33m'
        echo    
        [ `pacman -Qu | wc -l` -ne 0 ] && ( printf "${red}Available updates:\n"; cat /var/log/updpackages.log; printf "${nc}\n" ) || echo "System is up-to-date"
        printf "${yellow}$(~/instance/scripts/systemage.sh)${nc}\n"
        [ `who | wc -l` -ne 0 ] printf "${yellow}Login warning:$(who)${nc}\n" 
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
