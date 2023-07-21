#!/bin/env bash

color="#73d0ff" # blue
bulb=""
backlight='/sys/class/backlight/intel_backlight'
max_brightness=$(cat "$backlight/max_brightness")
pct_per_nits=$((max_brightness / 100))

get_fifo() {
	[ -p /tmp/backlight-fifo ] || mkfifo /tmp/backlight-fifo
	echo "/tmp/backlight-fifo"
}

pct_of() {
	echo $(($1 * 100 / "$2"))
}

get_brightness() {
	cat "$backlight/actual_brightness"
}

write() {
	echo "%{T2}%{F$color}$bulb $1%%{F-}%{T-}"
}

report() {
	pct=$(get_pct)
  write "$pct"
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
	new_brightness=$((pct * pct_per_nits))
	set_nits $new_brightness
	fifo="$(get_fifo)"
	echo "$pct" >"$fifo"
}

inc() {
	curr=$(get_pct)
	set_pct $((curr + $1))
}

dec() {
	curr=$(get_pct)
	set_pct $((curr - $1))
}

poll() {
	current="$backlight/actual_brightness"
	prev=$(cat "$current")
	while true; do
		new=$(cat "$current")
		if [ "$new" != "$prev" ]; then
			report
		fi
		prev="$new"
		sleep 2
	done
}

tail_fifo() {
	while read -r e; do
    write "$e"
	done < <(tail -f "$(get_fifo)")
}

do_tail() {
	report
	poll &
	tail_fifo
}

arg="$1"

case "$arg" in
--tail) do_tail ;;
--set) set_pct "$2" ;;
--inc) inc "$2" ;;
--dec) dec "$2" ;;
*) echo "Unrecognized option '$*'" ;;
esac
