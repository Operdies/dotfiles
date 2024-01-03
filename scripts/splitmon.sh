#!/bin/sh

# derived from xrandr output:
# DisplayPort-0 connected primary 5120x1440+0+0 (normal left inverted right x axis y axis) 1190mm x 340mm
H=1440
H_MM=340
case "$1" in
	split3)
		W1=$((5120/4))
		W1_MM=$((1190/4))
		W2=$((5120/2))
		W2_MM=$((1190/2))
		xrandr --setmonitor vir1 "${W1}/${W1_MM}x${H}/${H_MM}+0+0" DisplayPort-0
		xrandr --setmonitor vir2 "${W2}/${W2_MM}x${H}/${H_MM}+${W1}+0" none
		xrandr --setmonitor vir3 "${W1}/${W1_MM}x${H}/${H_MM}+$((W1*3))+0" none
		;;
	split)
		W=$((5120/2))
		W_MM=$((1190/2))
		xrandr --setmonitor vir1 "${W}/${W_MM}x${H}/${H_MM}+0+0" DisplayPort-0
		xrandr --setmonitor vir2 "${W}/${W_MM}x${H}/${H_MM}+${W}+0" none
		;;
	unsplit)
		xrandr --delmonitor vir1
		xrandr --delmonitor vir2
		xrandr --delmonitor vir3
		;;
esac

