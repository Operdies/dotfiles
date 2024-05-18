function ensure_fisher
    set fish_src "$HOME/.config/fish/functions/fisher.fish"
    # curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    if [ ! -f "$fish_src" ]
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end

    set plugins "catppuccin/fish" \
        "jorgebucaran/hydro" \
        "jethrokuan/z"
    set installed $(fisher list)
    for plugin in $plugins
        if not contains $plugin $installed
            fisher install $plugin
        end
    end
end


if status is-interactive
    set fish_greeting
    # Commands to run in interactive sessions can go here
    ensure_fisher
    fish_config theme choose "Catppuccin Mocha"
    bind \ea execute history-search-backward
end

