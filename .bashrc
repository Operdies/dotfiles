# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

[[ "$(whoami)" = "root" ]] && return

function has() {
  command -v "$@" > /dev/null 2>&1
}

export LANG=en_US.UTF-8

if [ "$(uname)" != "Darwin" ]; then
  # Taken from /etc/profile.d/debuginfod.sh
  if [ -z "$DEBUGINFOD_URLS" ]; then
      DEBUGINFOD_URLS=$(find "/etc/debuginfod" -name "*.urls" -print0 2>/dev/null | xargs -0 cat 2>/dev/null | tr '\n' ' ' || :)
      [ -n "$DEBUGINFOD_URLS" ] && export DEBUGINFOD_URLS || unset DEBUGINFOD_URLS
      if [ -z "$DEBUGINFOD_URLS" ]; then
        export DEBUGINFOD_URLS="https://debuginfod.s.voidlinux.org/"
      fi
  fi
fi

export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
if [ "$(uname)" = "Darwin" ]; then
  BREW="/opt/homebrew/bin/brew"
  [ -x "$BREW" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if has nvim; then
  # MANWIDTH fixes weird wrapping issues in neovim 
  export MANWIDTH=999
  export EDITOR='nvim'
  export MANPAGER='nvim +Man! -'
elif has vim; then
  export EDITOR='vim'
fi

# The wrapping issues don't occur in a "--clean" install, only with plugins.
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

[[ "$(whoami)" = "root" ]] && return

# Start desktop environment if
# fd 0 is open and refers to a terminal
# DISPAY variables are not set
# We are on tty1
if [ "$(uname)" != "Darwin" ]; then
  if [ -t 0 -a -z "${DISPLAY}" -a -z "$WAYLAND_DISPLAY" -a "$XDG_VTNR" = 1 ]; then
    ~/repos/dwl/startup.sh
    return
  fi
fi

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
  errors=("${PIPESTATUS[@]}")
  sum=0
  for err in ${errors[@]}; do
    sum=$((sum+err))
  done
  if ((sum > 0)); then
    printf '\e[0;33m<'
    if [[ ${#errors[@]} -gt 1 ]]; then
      printf ' %s |' ${errors[@]::${#errors[@]}-1}
    fi
    printf ' %s ' ${errors[${#errors[@]}-1]}
    printf '>\e[m'
  fi
}

function PS1_GITINFO() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    printf " @ %s" "$(git branch --show-current)"
  fi
}

function PS1_WHOAMI() {
  # remove trailing lan / local which is added on MacOS
  local host2="${HOSTNAME%.lan}"
  host2="${HOSTNAME%.local}"
  printf '\e[0;31m[%s@%s]\e[m' "$USER" "${host2}"
}

function PS1_WHEREAMI() {
  printf '\e[0;32m%s\e[m' "${PWD/"$HOME"/\~}"
}

PS1='$(PS1_EXITCODE)$(PS1_WHOAMI) $(PS1_WHEREAMI)$(PS1_GITINFO)\n❱ '
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

command -v zoxide > /dev/null 2>&1 && eval "$(zoxide init bash)"

function take() {
  mkdir -p "$@"
  cd "$@"
}

if [ -f ~/.bashrc_local ]; then
  source ~/.bashrc_local
fi
