PS1='\n\[\033[00;31m\]\h\[\033[00;37m\]:\[\033[00;34m\]\w\[\033[00m\] $ '

if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

complete -cf sudo

if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
        red='\033[0;31m'
        nc='\033[0m'
        yellow='\033[1;33m'
        green='\033[0;32m'
		uptime
        [ `pacman -Qu | grep -v "\[ignored\]" | wc -l` -ne 0 ] && printf "\n${yellow} Available updates:\n$(cat /var/log/updpackages.log)${nc}\n\n" || printf "\n${green} System is up-to-date${nc}\n"
        echo -n " "; ~/instance/scripts/age.sh 
		[ `systemctl list-units --failed | grep "listed" | cut -d" " -f1` -ne 0 ] && printf "\n${red} $(systemctl list-units --failed -q)${nc}\n"
        [ `who | grep pts | grep -v "tmux" | wc -l` -ne 1 ] && echo -e "\n${yellow} Login warning:\n$(who)${nc}\n" 
		echo; echo -n " "; ~/instance/scripts/logger.sh
fi

## don't duplicate lines in history file
export HISTCONTROL="erasedups:ignorespace"

## for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

## check the window size after each command and update values for columns
shopt -s checkwinsize
## type path and change directory without cd command
shopt -s autocd

## colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

## Search command in bash history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

SYSTEMD_LESS=FRXMK
