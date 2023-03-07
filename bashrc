PS1='\n\[\033[00;31m\]\h\[\033[00;37m\]:\[\033[00;34m\]\w\[\033[00m\] $ '

if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
fi

# https://wiki.archlinux.org/title/Bash#Common_programs_and_options
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
fi

# https://wiki.archlinux.org/title/Fzf#Bash
if [ -f /usr/share/fzf/completion.bash ]; then
	. /usr/share/fzf/completion.bash
fi
if [ -f /usr/share/fzf/key-bindings.bash ]; then
	. /usr/share/fzf/key-bindings.bash
fi

# https://wiki.archlinux.org/title/bash#History
## Search command in bash history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
## Don't duplicate lines in history file and don't save commands with starting space
export HISTCONTROL="erasedups:ignorespace"

# https://wiki.archlinux.org/title/bash#Auto_%22cd%22_when_entering_just_a_path
## Type path and change directory without cd command
shopt -s autocd

# https://wiki.archlinux.org/title/bash#Line_wrap_on_window_resize
## check the window size after each command and update values for columns
shopt -s checkwinsize

# https://wiki.archlinux.org/title/Systemd/Journal#Filtering_output Tip
SYSTEMD_LESS=FRXMK

# https://wiki.archlinux.org/title/Bash/Prompt_customization#Colors
## Some main colors for scripts
red='\033[0;31m';
yellow='\033[1;33m';
green='\033[0;32m';
nc='\033[0m';


## Quick server status for SSH conection
if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    uptime
    [ `systemctl list-units --failed | grep "listed" | cut -d" " -f1` -ne 0 ] && echo -e "\n${red} $(systemctl list-units --failed -q)${nc}\n"
    [ `who | grep pts | grep -v "tmux" | wc -l` -ne 1 ] && echo -e "\n${yellow} Login warning:\n$(who)${nc}\n"
fi

#INSTANCE PROJECT SCRIPTS:
if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    if [ -f /var/log/updpackages.log ]; then
	if [ `pacman -Qu | grep -v "\[ignored\]" | wc -l` -ne 0 ]; then
	    echo -e "\n${yellow} Available updates:\n$(cat /var/log/updpackages.log)${nc}\n"
	else
	    echo -e "\n${green} System is up-to-date${nc}\n"
	fi
    fi

    if [ -f ~/instance/scripts/age.sh ]; then
		echo -n " "; 
		~/instance/scripts/age.sh
		echo
    fi

    if [ -f ~/instance/scripts/logger.sh ]; then
		echo -n " "; 
		~/instance/scripts/logger.sh
		echo
    fi
fi
