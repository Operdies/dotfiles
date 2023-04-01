#!/usr/bin/env bash

case $1 in
left | right)
	polybar "$1" -c ~/.config/polybar/config.ini &
	;;
kill)
	# Terminate already running bar instances
	killall -q polybar
	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
	;;
*)
	MONITOR="$1" polybar generic -c ~/.config/polybar/config.ini &
	;;

esac
