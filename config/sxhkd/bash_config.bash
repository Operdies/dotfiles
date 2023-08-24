#!/bin/env bash

pkill -USR1 -x rhkd

rhkc() {
	~/.cargo/bin/rhkc "$@"
}

bind_unconditional() {
	if [ -z ${FLAGS+x} ] || [ -z "$FLAGS" ]; then
		FLAGS=()
	fi

	for ((i = 0; i < ${#BINDINGS[@]}; i += 3)); do
		bin="${BINDINGS[i]}"
		hotkey="${BINDINGS[i + 1]}"
		description="${BINDINGS[i + 2]}"
		dunstify unconditional "c $bin h $hotkey d $description"
		rhkc bind "$PREFIX$hotkey" -c "$bin" -d "$description" "${FLAGS[@]}"
	done
}

bind_conditional() {
	if [ -z ${FLAGS+x} ] || [ -z "$FLAGS" ]; then
		FLAGS=()
	fi

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
			rhkc bind "$PREFIX$hotkey" -c "$command" -d "$description" "${FLAGS[@]}"
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
	)
	PREFIX='super + r ; '
	FLAGS=(-t "Launch Program")
	bind_conditional
}

common_apps

terminal() {
	PREFIX='super + '
	FLAGS=()
	# Set xfce4-terminal as main terminal, and wezterm as fallback
	BINDINGS=(
		'xfce4-terminal' Return 'xfce4-terminal'
		'wezterm:wezterm start' Return 'Wezterm'
	)

	bind_conditional
}

terminal
