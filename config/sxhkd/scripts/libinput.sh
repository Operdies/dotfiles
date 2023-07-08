#!/bin/bash

get_touchpad() {
	xinput --list | grep Touchpad | grep -P --only-matching 'id=\d+' | cut -d= -f2
}

get_props() {
	xinput --list-props $(get_touchpad) | tr -d $'\t' | grep "^libinput" | cut -d' ' --complement -f1
}

get_options() {
	echo 0
	echo 1
}

set_option() {
	echo 1
}

cmd() {
	case $1 in
	props)
		get_props
		;;
	options)
		get_options
		;;
	set)
		set-option $2 $3
		;;
	esac
}

rofi() {
	command rofi -dmenu -i -window-title "$1"
}

case $1 in
wizard)
	prop="$(get_props | rofi 'Select a property')"
	if [ -n "$prop" ]; then
		propId="$(echo $prop | grep -P --only-matching "\(\d+\)" | tr -d '()')"
		if [ -n "$propId" ]; then
			prettyName="$(echo $prop | sed 's/ (.*//g')"
			value="$(get_options | rofi "Set '$prettyName' to what?")"
			xinput --set-prop $(get_touchpad) $propId $value
		fi
	else
		echo You chose nothing
	fi
	;;
esac
