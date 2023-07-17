#!/bin/env bash

has() {
	which "$1" 2>/dev/null >/dev/null
}

ensure_binaries() {
	binaries=(
		rg ripgrep
    xautolock xautolock
    htop htop
    lazygit lazygit
    tldr tldr
    hush hush-bin
    bsp-layout bsp-layout
		git git
		curl curl
		go go
    yq go-yq
		nvim neovim
		cargo rustup
		zsh zsh
    qutebrowser "qutebrowser python-adblock"
    gcc gcc
    npm npm
    wezterm wezterm
	)

	missing=()
	for ((i = 0; i < ${#binaries[@]}; i += 2)); do
		bin=${binaries[i]}
		source=${binaries[i + 1]}

		if has $bin; then
			echo "binary $bin is installed from package $source"
		else
			echo "binary $bin is missing, but can be installed from $source"
			missing+=($source)
		fi
	done

	if ((${#missing[@]} > 0)); then
		mpkg="${missing[@]}"
		echo "Missing packages: $mpkg"

    cmd="yay -Sy $mpkg --noconfirm"
		while true; do
			read -p "Install missing packages? ($cmd) (yn) " yn
			case $yn in
			[yY]*)
				$cmd
				return
				;;
			[nN]*)
				echo skipping install
				return
				;;
			*)
				echo "Please answer yes or no."
				;;
			esac
		done
	fi
}

ensure_links() {
	for item in $(dirname "$0")/config/*; do
		target="$HOME/.config/$(basename $item)"
		if [ -h "$target" ]; then
			echo "Skipping target '$target': File exists and is a symlink"
		else
			if [ -e "$target" ]; then
				echo "'$target' exists. Renaming to '$target.bak'."
				mv "$target" "$target.bak"
			fi
			ln -s "$item" "$target"
			echo "Created symlink: '$item' -> '$target'"
		fi
	done
}

ensure_links
ensure_binaries
