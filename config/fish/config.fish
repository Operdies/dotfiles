if status is-interactive
    set _fisher_src_marker "$HOME/.config/fish/functions/fisher.fish"
    # curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    if [ ! -f "$_fisher_src_marker" ]
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end

    set plugins "jorgebucaran/fisher" \
    "catppuccin/fish" \
    "jorgebucaran/hydro" \
    "jethrokuan/z" \
    "2m/fish-history-merge"
    set installed $(fisher list)
    for plugin in $plugins
        if not contains $plugin $installed
            fisher install $plugin
        end
    end
    for plugin in $(fisher list)
        if not contains $plugin $plugins
            fisher remove $plugin
        end
    end

    fish_config theme choose "Catppuccin Mocha"

    # startx on login on VT 1 if no display is set and the current session is on a tty
    if [ -t 0 -a -z "$DISPLAY" -a "$XDG_VTNR" -eq 1 -a ]
        startx
    end
end

