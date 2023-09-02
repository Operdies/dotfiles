#!/bin/env bash

setxkbmap us -variant altgr-intl
setxkbmap -option caps:escape

DEFAULT_PREFIX='@Super_L'

pkill -USR1 -x rhkd

rhkc() {
	~/.cargo/bin/rhkc "$@"
}

bind_unconditional() {
	for ((i = 0; i < ${#BINDINGS[@]}; i += 3)); do
		bin="${BINDINGS[i]}"
		hotkey="${BINDINGS[i + 1]}"
		description="${BINDINGS[i + 2]}"
		dunstify unconditional "c $bin h $hotkey d $description"
		rhkc bind "$PREFIX$hotkey" -c "$bin" -d "$description" "$@"
	done
}

bind_conditional() {
	for ((i = 0; i < ${#BINDINGS[@]}; i += 3)); do
		bin="${BINDINGS[i]}"
		hotkey="${BINDINGS[i + 1]}"
		description="${BINDINGS[i + 2]}"

		# Optionally, the binary and the command can be decoupled.
		# The command portion will be bound iff the specified binary or file exists
		# Take everything before the first colon
		binary=${bin%%:*}
		# Take everything after the first colon
		command=${bin#*:}

		if command -v $binary; then
			rhkc bind "$PREFIX$hotkey" -c "$command" -d "$description" "$@"
		fi
	done
}

common_apps() {
	# binary hotkey description
	BINDINGS=(
		discord d Discord
		steam s Steam
		teams-for-linux t 'Teams'
		hakuneko-desktop m 'Manga Reader'
		qutebrowser q 'Qutebrowser'
		firefox f 'Firefox'
		pavucontrol p 'pavucontrol'
		'xfce4-terminal:xfce4-terminal -e "tmux attach"' x 'tmux attach most recent'
	)

	PREFIX="$DEFAULT_PREFIX ; r ; "
	bind_conditional -t "Launch Program" --overwrite
}

common_apps

terminal() {
	PREFIX="$DEFAULT_PREFIX ; "
	# Set xfce4-terminal as main terminal, and wezterm as fallback
	BINDINGS=(
		'xfce4-terminal' Return 'xfce4-terminal'
		'wezterm:wezterm start' Return 'Wezterm'
	)

	bind_conditional -t terminal

	# crutch
	PREFIX='super + '
	bind_conditional -t terminal
}

terminal

etcetera() {
	PREFIX="$DEFAULT_PREFIX ; "
	BINDINGS=(
		'rofi -modi drun -show drun -line-padding 4 -columns 2 -padding 50 -hide-scrollbar -terminal xfce4-terminal -show-icons -drun-icon-theme "Arc-X-D" -font "Droid Sans Regular 10"'
		d
		'Rofi Launcher'
	)
	bind_unconditional -t "Do.." -o
	BINDINGS=(
		'bspc node -t {tiled;bsp-layout set tiled,floating,fullscreen}'
		't ; {t,s,f}'
		'{tiled,floating,fullscreen}'
	)
	bind_unconditional -t "Manage Layout" -o
	BINDINGS=(
		'bspc node -{c,k,f next.local.!hidden.window}'
		'n : {c,k,f}'
		'{close,kill,next} window'
	)
	bind_unconditional -t "Manage Windows" -o

	BINDINGS=(
		'bspc desktop -f ^{1-9,10}'
		'c : {q,w,e,r,t,y,u,i,o,p}'
		'Switch to workspace {1-9,10}'
	)
	bind_unconditional -t "Switch Workspace" -o
	BINDINGS=(
		'bspc node -d ^{1-9,10}'
		'c : {a,s,d,f,g,h,j,k,l,semicolon}'
		'Send window to workspace {1-9,10}'
	)
	bind_unconditional -t "Move Windows" -o
	BINDINGS=(
		'bspc node -f {next,prev}.local.!hidden.window'
		'c : {c,x}'
		'{next,previous} window'
	)
	bind_unconditional -t "Cycle Windows" -o
}

etcetera

power() {
	PREFIX="$DEFAULT_PREFIX ; "
	lock='~/.config/bspwm/scripts/i3lock-fancy/i3lock-minimalist.sh'
	BINDINGS=(
		"{$lock,bspc quit,systemctl poweroff,systemctl reboot,$lock; systemctl suspend}"
		'e ; {q,w,e,r,t}'
		'{ Lock,󰗼 Logout, Shutdown,󰁯 Reboot, Sleep}'
	)
	bind_unconditional -t "Power Menu" -o
}
power

reload() {
	PREFIX="$DEFAULT_PREFIX ; q ; "
	BINDINGS=(
		'bspc wm -r' w 'Reload bspwm'
		'~/.config/sxhkd/bash_config.bash' r 'Reload rhkd'
	)
	bind_unconditional -t 'Reload' -o
}
reload
