#!/bin/env bash

has() {
	which "$1" 2>/dev/null >/dev/null
}

ensure_binaries() {
	binaries=(
		nvr neovim-remote
		discord "discord noto-fonts-emoji"
		fd fd
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
		xwininfo xorg-xwininfo
		cargo rustup
		zsh zsh
		qutebrowser "qutebrowser python-adblock"
		gcc gcc
		npm npm
		wezterm wezterm
		tmux tmux
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
		mpkg="${missing[*]}"
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
	for item in "$(dirname "$0")/config/"*; do
		item="$(readlink -f "$item")"
		target="$HOME/.config/$(basename "$item")"
		if [ -h "$target" ] && readlink -f "$target"; then
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

ensure_clones() {
	REPO_DIR="$HOME/repos"
	[ -d "$REPO_DIR" ] || mkdir -p "$REPO_DIR"
	projects=(
		LazyVim
		gwatch.nvim
		gwatch
		sxhkd-whichkey
		polybar-iconography
	)
	pushd "$REPO_DIR" || return
	for ((i = 0; i < ${#projects[@]}; i += 2)); do
		project=${projects[i]}
		if ! [ -d "$REPO_DIR/$project" ]; then
			echo "Cloning $project"
			git clone "git@github.com:operdies/$project"
		else
			echo "$project exists -- skip"
		fi
	done
	popd || return
}

ensure_links
ensure_binaries
ensure_clones
