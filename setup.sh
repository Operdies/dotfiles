#!/bin/env bash

has() {
	which "$1" 2>/dev/null >/dev/null
}

INSTALLED=($(pacman -Qq))

has_pkg() {
	local needle="$1"
	local start=0
	local end=${#INSTALLED[@]}
	local count=$end

	local prevguess=0
	while [[ "$guess" != "$prevguess" ]]; do
		prevguess=$guess
		local guess="$(((end - start) / 2 + start))"
		local item=${INSTALLED[guess]}

		if [ "$item" == "$needle" ]
		then
			return 0
		elif [ "$item" \< "$needle" ]
		then
			start=$guess
		else
			end=$guess
		fi
	done
	return 1
}

ensure_yay() {
	has yay || {
		echo "Installing yay."
		sudo pacman -Syu --needed base-devel git
		git clone https://aur.archlinux.org/yay.git /tmp/yay
		pushd /tmp/yay
		makepkg -si
		yay --version || (echo "yay installation failed." && exit 1)
		popd
		rm -rf /tmp/yay
	}
}

ensure_binaries() {
	packages=(
		arc-gtk-theme 
		ctags
		curl
		dmenu networkmanager-dmenu-git
		fd
		feh
		firefox
		freetype2 
		fzf
		gcc gdb
		git
		go
		gsimplecal
		gvim
		htop
		imagemagick
		iw iwd
		lazygit
		libinput xf86-input-libinput libinput-gestures
		libnotify
		man-db man-pages less
		networkmanager
		nitrogen
		noto-fonts noto-fonts-emoji
		picom
		powertop
		ripgrep
		rofi
		rustup
		sudo
		tldr
		tmux
		xautolock i3lock
		xfce-polkit dex
		xorg-server xorg-xinit libx11 libxft libxinerama freetype2 
		xorg-xinput xdotool xorg-xwininfo xdg-utils xclip tiramisu-git
		zathura zathura-pdf-mupdf
		zsh ttf-meslo-nerd-font-powerlevel10k 
	)

	missing=()

	for ((i = 0; i < ${#packages[@]}; i++)); do
		pkg=${packages[i]}

		if ! has_pkg $pkg; then
			echo "package $pkg is missing"
			missing+=($pkg)
		fi
	done

	if ((${#missing[@]} > 0)); then
		mpkg="${missing[*]}"
		echo "Missing packages: $mpkg"

		cmd="yay -Sy $mpkg --noconfirm --needed"
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
		if [[ "$INSTALL" == 1 ]]; then
			make install
		fi
		popd
	done
}

set_default_apps() {
	# check filetype with e.g. xdg-mime query filetype <file>
	xdg-mime default org.pwmt.zathura.desktop application/pdf
	xdg-mime default firefox.desktop x-scheme-handler/https x-scheme-handler/http
	xdg-mime default feh.desktop image/png
	xdg-mime default feh.desktop image/jpeg
}

case "$1" in
	install)
		INSTALL=1
		ensure_make
		;;
	*)
		ensure_links
		ensure_yay
		ensure_binaries
		ensure_clones
		ensure_make
		set_default_apps
		;;
esac

