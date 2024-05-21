export LANG=en_US.UTF-8
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org/"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR='nvim'
export FZF_DEFAULT_OPTS='--layout=reverse'
export MANPAGER='nvim +Man! -'

# don't nest nvim
if [ -n "$NVIM" ]
    if command -v nvr &> /dev/null
        alias nvim="nvr -l"
        export MANPAGER='nvr -l +Man! -'
        export EDITOR='nvr -l'
    end
end

set fish_greeting
set hydro_multiline true
set hydro_color_pwd 6bb0f0
set hydro_color_error f02020
set fish_prompt_pwd_dir_length 10
