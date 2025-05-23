#!/bin/env bash

has() {
	which "$1" 2>/dev/null >/dev/null
}

INSTALLED=($(pacman -Qq))
HERE="$(dirname "$0")"
cd "$HERE"

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

		if [ "$item" == "$needle" ]; then
			return 0
		elif [ "$item" \< "$needle" ]; then
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
		arc-gtk-theme nitrogen
		bash bash-completion
		curl
		discord
		dmenu networkmanager-dmenu-git rofi
		fd fzf ripgrep
		feh zathura zathura-pdf-mupdf
		firefox
		fish
		gcc gdb go rustup npm git ctags
		gsimplecal
		gitmux # required to show git status in tmux
		htop powertop lazygit
		imagemagick
		inotify-tools
		kwallet # keyring
		libbsd # neat C headers
		libinput xf86-input-libinput libinput-gestures # touchpad gestures
		libnotify tiramisu-git # simple notification daemon that writes to stdout
		mako # notification daemon
		man-db man-pages less
		mesa # picom requires iris_dri.so for the glx backed which is provided by mesa, but not mesa-amber
		networkmanager iw iwd # wifi + wifi cli tools
		noto-fonts noto-fonts-emoji # needed for Discord to display emojis
		picom
		qmk udisks2 # flash keyboard + mount liatris controller
		slurp grim # wayland screenshots
		sudo
		swaybg swayidle swaylock waybar # thank you sway community for making compositor agnostic utils
		thunar thunar-volman gvfs # gvfs is needed for volume management / fuse integration in thunar
		tldr
		tmux gvim # vim-minimal does not have clipboard integration
		unzip
		valgrind
		way-displays # daemon for display handling -- handles laptop lid closing / plugging new monitors
		wlroots wayland-protocols wofi xorg-xwayland # wayland stuff dependencies (dwl)
    wlr-which-key # nvim-which-key like launcher for wayland
		wmname # utility for setting the WM name (needed to fix broken java applications)
		xautolock i3lock
		xfce-polkit dex # polkit daemon + desktop launcher
		xclip wl-clipboard clipman # clipboard tools
		xorg-server xorg-xinit xorg-xinput xdotool xorg-xwininfo xdg-utils libx11 libxft libxinerama freetype2 
		xorg-xhost # needed for compatibility with some X apps (gparted)
		zsh ttf-meslo-nerd-font-powerlevel10k # need a chonky font for a chonky shell
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

		cmd="yay -Syu $mpkg --noconfirm --needed"
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
		sxhkd-whichkey
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

ensure_etc() {
  find etc -type f | xargs -I{} install -v --owner=root -D {} /{}
}

set_default_apps() {
	# check filetype with e.g. xdg-mime query filetype <file>
	xdg-mime default org.pwmt.zathura.desktop application/pdf
	xdg-mime default firefox.desktop x-scheme-handler/https x-scheme-handler/http
	xdg-mime default feh.desktop image/png
	xdg-mime default feh.desktop image/jpeg
	xdg-mime default thunar.desktop inode/directory
}

case "$1" in
	install)
		INSTALL=1
		ensure_make
		;;
  etc)
    ensure_etc
    ;;
	*)
		if [ "$EUID" -eq 0 ]; then
			echo "Don't run setup as root"
			exit 1
		fi
		ensure_links
		ensure_yay
		ensure_binaries
		ensure_clones
		ensure_make
		set_default_apps
		;;
esac

