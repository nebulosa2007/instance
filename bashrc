# Program packages:
# paru -Syu --needed bash_completion fzf git tmux

case $- in
  *i*)
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

# https://wiki.archlinux.org/title/Git#Bash_completion
if [ -f /usr/share/git/completion/git-completion.bash ]; then
    . /usr/share/git/completion/git-completion.bash
fi

#https://wiki.archlinux.org/title/Git#Git_prompt
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    export GIT_PS1_SHOWDIRTYSTATE=on        # any nonempty value. + for staged, * if unstaged
    export GIT_PS1_SHOWSTASHSTATE=on        # any nonempty value. $ if something is stashed
    export GIT_PS1_SHOWUNTRACKEDFILES=on    # any nonempty value. % if there are untracked files
    export GIT_PS1_SHOWUPSTREAM="verbose"   # auto: <, >, <> behind, ahead, or diverged from upstream
                                            # or a space-delimited list of the following options (verbose .. .. ..):
                                            # verbose  show number of commits ahead/behind (+/-) upstream
                                            # name     if verbose, then also show the upstream abbrev name
                                            # legacy   don't use the '--count' option available in recent versions of git-rev-list
                                            # git always compare HEAD to @{upstream}
                                            # svn always compare HEAD to your SVN upstream
    export GIT_PS1_STATESEPARATOR=" "       # separator between branch name and state symbols
    export GIT_PS1_DESCRIBE_STYLE="default" # show commit relative to tag or branch, when detached HEAD
    export GIT_PS1_SHOWCOLORHINTS=on        # any nonempty value. display in color
    . /usr/share/git/completion/git-prompt.sh
fi

PS1='\n \
$([ -n "$SSH_CLIENT" ] && echo "\[\033[00;34m\]SSH\[\033[00;37m\]")\
$(__git_ps1 " (%s)") \
\[\033[00;3$([[ $(stat --printf="%U%a" "$(pwd)") == *$(whoami)7* ]] && echo 2 || echo 1)m\]\w\[\033[00m\] \
$ '

if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
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

# https://wiki.archlinux.org/title/Systemd/Journal#Filtering_output
SYSTEMD_LESS=FRXMK

# https://wiki.archlinux.org/title/Bash/Prompt_customization#Colors
## Some main colors for scripts
red='\033[0;31m';
yellow='\033[1;33m';
green='\033[0;32m';
blue='\033[0;34m';
nc='\033[0m';

## Adding date and time of execution in bash history
export HISTTIMEFORMAT=`echo -e "${blue}%F %T ${nc}"`

## Quick server status for SSH conection
if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    echo -ne "\n"; uptime;
    #[ `systemctl list-units --failed | grep "listed" | cut -d" " -f1` -ne 0 ] && echo -e "\n${red} $(systemctl list-units --failed -q)${nc}"
    [ "$(who | grep pts | grep -cv 'tmux')" -ne 1 ] && echo -e "\n${yellow} Login warning:\n$(who | sed 's/^/ /')${nc}"
    # https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#.pacnew
    PACNEWCOUNT=$(find /etc -name '*.pacnew' 2>/dev/null | wc -l)
    [ "$PACNEWCOUNT" -ne 0 ] && echo -e "\n Pacnew files: $PACNEWCOUNT update""$([ "$PACNEWCOUNT" -ne 1 ] && echo -n 's')"" remaining"
fi


#INSTANCE PROJECT SCRIPTS:

[ "$(systemctl list-units --failed        | grep "listed" | cut -d" " -f1)" -ne 0 ] && echo -e "\n${red} $(systemctl list-units --failed -q)${nc}"
[ "$(systemctl list-units --user --failed | grep "listed" | cut -d" " -f1)" -ne 0 ] && echo -e "\n${red} $(systemctl list-units --user --failed -q)${nc}"


if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    if [ -f /var/log/updpackages.log ] && [ "$(pacman -Qu | grep -cv "\[ignored\]")" -ne 0 ]; then
        echo -e "\n${yellow} Available updates:\n$(sed 's/<[^>]*>//g;s/^/ /' < /var/log/updpackages.log | tail -n+2 )${nc}"
    else
        echo -e "\n${green} System is up-to-date${nc}"
    fi

    if [ -z "$PATHINSTANCE" ]; then
        echo "Please set $PATHINSTANCE env variable in /etc/profile.d/instance.sh!"
    fi

    if [ -f "$PATHINSTANCE"/scripts/age.sh ]; then
        echo -ne "\n ";
        "$PATHINSTANCE"/scripts/age.sh
    fi

    if [ -f "$PATHINSTANCE"/scripts/logger.sh ]; then
        echo -ne "\n";
        "$PATHINSTANCE"/scripts/logger.sh
    fi
fi

# Check if the tmux session exists, discarding output (zero for success, non-zero for failure)
if [ -n "$SSH_CLIENT" ]; then
    if tmux has-session -t 0 &>/dev/null && [ -z "$TMUX" ]; then
        echo -ne "\n${yellow}Attaching to an existing tmux session"
        for i in {1..3}; do echo -n "."; sleep 1; done;  echo -e "${nc}"
        tmux attach-session -t 0
    fi
fi
;;
esac
