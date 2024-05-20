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

    function execute-and-restore
        set -g __fish_pushed_line (commandline)
        set -g __fish_cursor_pos (commandline -C)
        commandline -f execute
        function on-next-prompt --on-event fish_postexec
            commandline $__fish_pushed_line
            commandline -C $__fish_cursor_pos
            functions --erase on-next-prompt
        end
    end
    bind \ea execute-and-restore

    function push-line
        set -g __fish_pushed_line (commandline)
        commandline ""
        function on-next-prompt --on-event fish_postexec
            commandline $__fish_pushed_line
            functions --erase on-next-prompt
        end
    end
    bind \cq push-line

    # startx on login on VT 1 if no display is set and the current session is on a tty
    if [ -t 0 -a -z "$DISPLAY" -a "$XDG_VTNR" -eq 1 -a ]
        startx
    end
end

