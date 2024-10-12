# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

[[ "$(whoami)" = "root" ]] && return

export LANG=en_US.UTF-8
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org/"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='nvim'
export FZF_DEFAULT_OPTS='--layout=reverse'
export MANPAGER='nvim +Man! -'
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000

# Start desktop environment if
# fd 0 is open and refers to a terminal
# DISPAY variables are not set
# We are on tty1
[ -t 0 -a -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a "$XDG_VTNR" = 1 ] && ~/repos/dwl/startup.sh && return

[[ -z "$FUNCNEST" ]] && export FUNCNEST=100          # limits recursive functions, see 'man bash'

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

bind -x '"\C-[s":"git status"'
bind -x '"\C-[r":"source ~/.bashrc"'
bind -x '"\C-[l":"ls"'
bind -s '"\C-q":complete'

shopt -s histappend
bind -s 'set completion-ignore-case on'
bind -s 'set show-all-if-ambiguous on'
bind -s 'set menu-complete-display-prefix on'

bind 'TAB:menu-complete'
# shift-tab
bind '"\e[Z":menu-complete-backward'
# M-q
bind '"\C-[q":complete'
# M-w
bind '"\ew":backward-kill-word'


function PS1_EXITCODE() {
  err=$?
  # if ! [ err -eq 0 ]; then echo "\e[0;31m$err \e[m"; fi
  [ $err -ne 0 ] && printf '\e[0;31m%s | \e[m' "$err"
}

function PS1_GITINFO() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    printf " @ %s" "$(git branch --show-current)"
  fi
}

function PS1_WHOAMI() {
  printf '\e[0;31m[%s@%s]\e[m' "$USER" "$HOSTNAME"
}

function PS1_WHEREAMI() {
  printf '\e[0;32m%s\e[m' "${PWD/"$HOME"/"~"}"
}

PS1='$(PS1_EXITCODE)$(PS1_WHOAMI) $(PS1_WHEREAMI)$(PS1_GITINFO)\n❱ '
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

command -v zoxide > /dev/null 2>&1 && eval "$(zoxide init bash)"

function take() {
  mkdir -p "$@"
  cd "$@"
}
