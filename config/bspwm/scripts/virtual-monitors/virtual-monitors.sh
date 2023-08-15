#!/bin/env bash

create_virtual_monitor() {
	local name="${1}"
	local width="${2}"
	local height="${3}"
	local offset="${4}"

	local rect="${width}x${height}+${offset}+0"
	if bspc query -M --names | grep -q "$name"; then
		bspc monitor "$name" -g "$rect"
	else
		bspc wm -a "$name" "$rect"
	fi
}

get_dimensions() {
	local monitor="${1}"
	bspc query -m "$monitor" -T | yq '.rectangle | [.width, .height][]'
}

virtual_split() {
	~/.screenlayout/monitor.sh
	bspc wm --record-history off
	local FOCUSED="$(bspc query -n focused -N)"
	local DISPLAY_NAME="${1}"
	local RATIO="${2}"
	local dims=($(get_dimensions "$DISPLAY_NAME"))
	local WIDTH="${dims[0]}"
	local HEIGHT="${dims[1]}"
	local LEFT="${DISPLAY_NAME}-left"
	local RIGHT="${DISPLAY_NAME}-right"
	local LEFT_WIDTH="$(echo "($WIDTH * $RATIO) / 1" | bc)"
	local RIGHT_WIDTH=$((WIDTH - LEFT_WIDTH))

	bspc monitor -f "$DISPLAY_NAME"

	create_virtual_monitor "$LEFT" "$LEFT_WIDTH" "$HEIGHT" 0
	create_virtual_monitor "$RIGHT" "$RIGHT_WIDTH" "$HEIGHT" "$LEFT_WIDTH"

	bspc monitor "$LEFT" -d 1 2 3
	bspc monitor "$RIGHT" -d 4 5 6
	# bspc monitor "$DISPLAY_NAME" -d 7

	bspc wm --adopt-orphans
	bspc wm --reorder-monitors "$LEFT" "$RIGHT" "$DISPLAY_NAME"
	bspc node -f "$FOCUSED"
	bspc wm --record-history on
}

split() {
	monitor="${1}"
	ratio="${2}"
	virtual_split "$monitor" "$ratio"
}

arg="$1"
shift

case $arg in
split)
	split "$@"
	;;
test)
	arr=($(get_dimensions "DP1"))
	echo "Width: ${arr[0]}, width: ${arr[1]}"
	;;
*) ;;
esac
