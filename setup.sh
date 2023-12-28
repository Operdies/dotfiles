#!/bin/env bash

has() {
	which "$1" 2>/dev/null >/dev/null
}

ensure_binaries() {
	binaries=(
		bsp-layout bsp-layout
		cargo rustup
		curl curl
		discord "discord noto-fonts-emoji"
		dmenu dmenu
		fd fd
		gcc gcc
		git git
		go go
		gsimplecal gsimplecal
		gvim gvim # don't need the gui, but gvim includes X11 clipboard
		htop htop
		lazygit lazygit
		libinput-gestures "libinput libinput-gestures xf86-input-libinput"
		networkmanager_dmenu networkmanager_dmenu
		npm npm
		nvim neovim
		nvr neovim-remote
		picom picom
		rg ripgrep
		tldr tldr
		tmux tmux
		wezterm wezterm
		xautolock xautolock
		xwininfo xorg-xwininfo
		yq go-yq
		zathura "zathura zathura-pdf-mupdf"
		zsh zsh
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

mylink() {
	item="$(readlink -f "$1")"
	target="$2"
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

}

ensure_links() {
	for item in "$(dirname "$0")/config/"*; do
		item="$(readlink -f "$item")"
		target="$HOME/.config/$(basename "$item")"
		mylink "$item" "$target"
	done
}

ensure_clones() {
	REPO_DIR="$HOME/repos"
	[ -d "$REPO_DIR" ] || mkdir -p "$REPO_DIR"
	projects=(
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

ensure_make() {
	for item in "$(dirname "$0")/src/"*; do
		dir="$(readlink -f "$item")"
		pushd "$dir"
		make
		popd
	done
}

set_default_apps() {
	xdg-mime default org.pwmt.zathura.desktop application/pdf
	xdg-mime default firefox.desktop x-scheme-handler/https x-scheme-handler/http
}

ensure_links
ensure_binaries
ensure_clones
ensure_make
set_default_apps
