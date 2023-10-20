# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH:$HOME/go/bin:$HOME/.cargo/bin

export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Preload oh-my-zsh and required plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}
[ -d ~/.oh-my-zsh ] || sh -c "git clone https://github.com/ohmyzsh/ohmyzsh.git $ZSH && compaudit | xargs chmod g-w,o-w $ZSH"
[ -d $ZSH_CUSTOM/themes/powerlevel10k ] || sh -c "git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k"
[ -d $ZSH_CUSTOM/plugins/zsh-syntax-highlighting ] || sh -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ] || sh -c "git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d $ZSH_CUSTOM/plugins/zsh-z ] || sh -c "git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-z)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor
export EDITOR='nvim'

export BAT_THEME=base16
export FZF_DEFAULT_OPTS='--layout=reverse'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# add npm binaries
PATH="$HOME/.node_modules/bin:$PATH"
export npm_config_prefix=~/.node_modules

export MANPAGER='nvim +Man! "+let g:auto_session_enabled = v:false"'

# opt out of autocd
unsetopt autocd

# don't nest nvim
if [ -n "$NVIM" ]; then
  if command -v nvr &> /dev/null; then
    alias nvim="nvr -l"
    export MANPAGER='nvr -l +Man! -'
    export EDITOR='nvr -l'
  fi
fi

export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

autoload -U compinit; compinit
autoload -U +X bashcompinit && bashcompinit

alias yank='xclip -selection clipboard'
# Disable gdb download prompt
unset DEBUGINFOD_URLS

export KUBECONFIG=~/repos/helm-charts/charts/ks8500/.debug/output/kubeconfig.yaml
