#!/bin/env bash

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

	PREFIX='alt + Escape ; r ; '
	bind_conditional -t "Launch Program" --overwrite
}

common_apps

terminal() {
	PREFIX='alt + Escape ; '
	# Set xfce4-terminal as main terminal, and wezterm as fallback
	BINDINGS=(
		'xfce4-terminal' Return 'xfce4-terminal'
		'wezterm:wezterm start' Return 'Wezterm'
	)

	bind_conditional -t terminal
}

terminal

rest() {
	PREFIX='alt + Escape ; '
	BINDINGS=(
		'rofi -modi drun -show drun -line-padding 4 -columns 2 -padding 50 -hide-scrollbar -terminal xfce4-terminal -show-icons -drun-icon-theme "Arc-X-D" -font "Droid Sans Regular 10"' d 'Rofi Launcher'
	)
	bind_unconditional -t "Do.." -o
	BINDINGS=(
		'bspc node -t {tiled,floating,fullscreen}' 't ; {t,s,f}' '{tiled,floating,fullscreen}'
	)
	bind_unconditional -t "Manage Layout" -o
	BINDINGS=(
		'bspc node -{c,k,f next.local.!hidden.window}' 'n : {c,k,f}' '{close,kill,next} window'
	)
	bind_unconditional -t "Manage Windows" -o

	BINDINGS=(
    'bspc desktop -f ^{1-9,10}' 'c : {1-9,0}' 'Switch to workspace {1-9,10}'
	)
	bind_unconditional -t "Switch Workspace" -o
	BINDINGS=(
    'bspc node -d ^{1-9,10}' 'c : {q,w,e,r,t,y,u,i,o,p}' 'Send window to workspace {1-9,10}'
	)
	bind_unconditional -t "Move Windows" -o
	BINDINGS=(
		'bspc node -f {next,prev}.local.!hidden.window' 'c : {c,v}' '{next,previous} window'
	)
	bind_unconditional -t "Cycle Windows" -o
}

rest
