# ignore if non-interactive
case $- in
*i*) ;;
*) return ;;
esac

shopt -s checkwinsize \
    expand_aliases \
    histappend

HISTCONTROL=ignoredups
HISTFILESIZE=50000
HISTSIZE=10000
HISTTIMEFORMAT="%F %T "

alias ll="ls -lAh"
alias cd..="cd .."

bind 'set completion-ignore-case on'
if ! shopt -oq posix; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

PROMPT_COMMAND=__prompt_command
__prompt_command() {
    local last_exit_status="$?"
    PS1="\[\033[2m\]"
    if [[ "${last_exit_status}" != 0 ]]; then
        PS1+="=> \[\033[31m\]${last_exit_status}\[\033[39m\]\n"
    fi
    PS1+="\u@\h:\w\n\$\[\033[0m\] "
}
