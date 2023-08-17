#!/usr/bin/env bash

notify() {
	msg="$*"
	dunstify -u normal -t 2000 bspwmrc "$msg"
}

rand() {
	MIN="$1"
	MAX="$2"
	mod=$((MAX - MIN + 1))
	roll=$((RANDOM % mod))
	echo $((roll + MIN))
}

case $1 in
left | middle | right)
	polybar "$1" -c ~/.config/polybar/config.ini &
	;;
kill)
	# Terminate already running bar instances
	killall -q polybar
	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
	;;
*)
	if [ "$2" = "rand" ]; then
		WIDTH=$(rand 48 50)
		WIDTH=$((WIDTH * 2))
		OFFSET_X=$((100 - WIDTH))
		OFFSET_X=$((OFFSET_X / 2))
	else
		WIDTH=100
		OFFSET_X=0
	fi
	MONITOR="$1"
	MONITOR=$MONITOR WIDTH="$WIDTH%" OFFSET_X="$OFFSET_X%" polybar generic -c ~/.config/polybar/config.ini &
	;;

esac
