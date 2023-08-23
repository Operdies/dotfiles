#!/bin/env bash

pkill -USR1 -x rhkd

rhkc() {
	~/.cargo/bin/rhkc "$@"
}

bind_unconditional() {
	title=
	if ! [ -z "$TITLE" ]; then
		title="-t $TITLE"
	fi

	for ((i = 0; i < ${#BINDINGS[@]}; i += 3)); do
		bin="${BINDINGS[i]}"
		hotkey="${BINDINGS[i + 1]}"
		description="${BINDINGS[i + 2]}"
		dunstify unconditional "c $bin h $hotkey d $description"
		rhkc bind "$PREFIX$hotkey" -c "$bin" -d "$description"
	done
}

bind_conditional() {
	title=
	if ! [ -z "$TITLE" ]; then
		title="-t $TITLE"
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
			rhkc bind "$PREFIX$hotkey" -c "$command" -d "$description" "$title"
		else
			dunstify "Not Bound: $PREFIX $hotkey" "$binary not found"
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

	TITLE="Launch Proggram" bind_conditional
}

common_apps
