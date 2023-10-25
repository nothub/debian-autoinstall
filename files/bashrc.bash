# ~/.bashrc: executed by bash(1) for non-login shells.

# ignore if non-interactive
case $- in
*i*) ;;
*) return ;;
esac

shopt -s checkwinsize \
    expand_aliases \
    histappend

HISTCONTROL=ignoredups
HISTFILESIZE=20000
HISTSIZE=10000
HISTTIMEFORMAT="%F %T "

alias ll="ls -lAh"
alias cd..="cd .."

bind 'set completion-ignore-case on'
if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        . /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        . /etc/bash_completion
    fi
fi

PROMPT_COMMAND=__prompt_command
__prompt_command() {
    local last_status="$?"
    PS1="\[\033[2m\]"
    if [[ "${last_status}" != 0 ]]; then PS1+="=> \[\033[31m\]${last_status}\[\033[39m\]\n"; fi
    if [[ $(id -u) -eq 0 ]]; then
        PS1+="\[\033[31m\]\u\[\033[39m\]"
    else
        PS1+="\u"
    fi
    PS1+="@$(hostname --fqdn):\w\n\$\[\033[0m\] "
}
