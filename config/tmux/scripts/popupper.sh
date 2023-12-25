#!/bin/sh

cleanup() {
	readarray -t parents <<< "$(tmux list-sessions -F#S | grep -v '\-popup$')"
	readarray -t popups <<< "$(tmux list-sessions -F#S | grep '\-popup$')"

	for ((i = 0; i < ${#popups[@]}; i++)); do
		session="${popups[i]}"
		parent="${session//-popup}"
		if ! printf '%s\n' "${parents[@]}" | grep -qx "$parent"; then
			tmux kill-session -t "$session"
		fi
	done
}

TITLE="$(tmux display-message -p '#S')"
if [[ "$TITLE" == *"-popup" ]]; then
	tmux detach-client
else
	cleanup
	tmux attach -t "$TITLE-popup" || tmux new -s "$TITLE-popup"
fi

