#!/bin/sh

if [ "$(tmux display-message -p '#S')" == "popup" ]; then
	tmux detach-client
else
	case "$1" in
		"")
			tmux attach -t popup || tmux new -s popup
			;;
		*)
			"$1"
			;;
	esac
fi

