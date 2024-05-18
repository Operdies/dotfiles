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

if status is-interactive
    function ensure_fisher
        set fish_src "$HOME/.config/fish/functions/fisher.fish"
        # curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
        if [ ! -f "$fish_src" ]
            curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
        end

        set plugins "catppuccin/fish" \
        "jorgebucaran/hydro" \
        "jethrokuan/z" \
        "2m/fish-history-merge"
        set installed $(fisher list)
        for plugin in $plugins
            if not contains $plugin $installed
                fisher install $plugin
            end
        end
    end

    set --universal fish_color_error 'ff0000'
    set fish_greeting

    ensure_fisher
    fish_config theme choose "Catppuccin Mocha"
    bind \ea execute history-search-backward

    # startx on login on VT 1 if no display is set and the current session is on a tty
    if [ -t 0 -a -z "$DISPLAY" -a "$XDG_VTNR" -eq 1 -a ]
        startx
    end
end

