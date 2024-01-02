#!/bin/env bash

has() {
	which "$1" 2>/dev/null >/dev/null
}

ensure_yay() {
	has yay || {
		echo "Instlling yay."
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
	binaries=(
		# Install fonts and libraries in addition to X
		X "xorg-server ttf-meslo-nerd-font-powerlevel10k libx11 libxinerama libxft freetype2 arc-gtk-theme"
		cargo rustup
		convert imagemagick
		ctags ctags
		curl curl
		dmenu dmenu
		fd fd
		feh feh
		firefox firefox
		fzf fzf
		gcc gcc
		gdb gdb
		git git
		go go
		gsimplecal gsimplecal
		gvim gvim # don't need the gui, but gvim includes X11 clipboard
		htop htop
		i3lock i3lock
		iw iw
		iwctl iwd
		lazygit lazygit
		less less
		libinput-gestures "libinput libinput-gestures xf86-input-libinput"
		man 'man-db man-pages'
		networkmanager_dmenu networkmanager-dmenu-git
		nitrogen nitrogen
		nmcli networkmanager
		notify-send libnotify
		picom picom
		powertop powertop
		rg ripgrep
		rofi rofi
		startx xorg-xinit
		sudo sudo
		tiramisu tiramisu-git
		tldr tldr
		tlp tlp
		tmux tmux
		xautolock xautolock
		xclip xclip
		xdg-mime xdg-utils
		xdotool xdotool
		xinput xorg-xinput
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
		sudo make install || echo "no make install"
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

ensure_links
ensure_yay
ensure_binaries
ensure_clones
ensure_make
set_default_apps
