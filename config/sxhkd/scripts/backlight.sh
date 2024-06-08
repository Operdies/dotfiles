#!/bin/env bash

backlight='/sys/class/backlight/intel_backlight'
max_brightness=$(cat "$backlight/max_brightness")
pct_per_nits=$((max_brightness / 100))

pct_of() {
	echo $(($1 * 100 / "$2"))
}

get_brightness() {
	cat "$backlight/actual_brightness"
}

get_pct() {
	pct_of "$(get_brightness)" max_brightness
}

set_nits() {
	echo "$1" >"$backlight/brightness"
}

pct_to_nits() {
	echo $(($1 * pct_per_nits))
}

set_pct() {
	pct=$1
	if ((pct < 1)); then
		pct=1
	elif ((pct > 100)); then
		pct=100
	fi
	new_brightness=$((pct * pct_per_nits))
	set_nits $new_brightness
}

inc() {
	curr=$(get_pct)
	set_pct $((curr + $1))
}

dec() {
	curr=$(get_pct)
	set_pct $((curr - $1))
}

arg="$1"

case "$arg" in
--set) set_pct "$2" ;;
--inc) inc "$2" ;;
--dec) dec "$2" ;;
--halve) set_pct $(($(get_pct) / 2)) ;;
--double) set_pct $(($(get_pct) * 2)) ;;
*) echo "Unrecognized option '$*'" ;;
esac
