#!/bin/sh

TITLE="$(tmux display-message -p '#S')"
if [[ "$TITLE" == *"-popup" ]]; then
	tmux detach-client
else
	case "$1" in
		"")
			tmux attach -t "$TITLE-popup" || tmux new -s "$TITLE-popup"
			;;
		*)
			"$1"
			;;
	esac
fi

