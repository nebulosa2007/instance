# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\n\[\033[00;31m\]\h\[\033[00;37m\]:\[\033[00;34m\]\w\[\033[00m\] $ '
	if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
	fi
complete -cf sudo
