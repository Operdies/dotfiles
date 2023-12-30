#!/bin/sh

# derived from xrandr output:
# DisplayPort-0 connected primary 5120x1440+0+0 (normal left inverted right x axis y axis) 1190mm x 340mm
W=$((5120/2))
W_MM=$((1190/2))
H=1440
H_MM=340

case "$1" in
	split)
		xrandr --setmonitor vir1 "${W}/${W_MM}x${H}/${H_MM}+0+0" DisplayPort-0
		xrandr --setmonitor vir2 "${W}/${W_MM}x${H}/${H_MM}+${W}+0" none
		;;
	unsplit)
		xrandr --delmonitor vir1
		xrandr --delmonitor vir2
		;;
esac

