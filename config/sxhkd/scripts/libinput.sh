#!/bin/bash

id=""
get_touchpad() {
	if [ -z "$id" ]; then
		id=$(xinput --list | grep " Touchpad " | grep -P --only-matching 'id=\d+' | cut -d= -f2)
	fi
	echo "$id"
}

get_trackpad() {
	if [ -z "$id" ]; then
		id=$(xinput --list | grep " Magic " | grep -P --only-matching 'id=\d+' | cut -d= -f2)
	fi
	echo "$id"
}

get_props() {
	xinput --list-props $(get_touchpad) | grep -v " Default" | tr -d $'\t' | grep "^libinput" | cut -d' ' --complement -f1
}

get_options() {
	echo 0
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

setProperty() {
	propId="$1"
	value="$2"
	echo xinput --set-prop $(get_touchpad) $propId $value
	xinput --set-prop $(get_touchpad) $propId $value
}

while [ ! -z "$1" ]; do
	case $1 in
	set)
		setting="$2"
		value="$3"
		guess="$(get_props | grep -i "$2" | head -n 1)"
		if [ -n "$guess" ]; then
			propId="$(echo $guess | grep -P --only-matching "\(\d+\)" | tr -d '()')"
	    echo "Guessed prop: '$guess' with id $propId. Setting value $value"
			setProperty "$propId" "$value"
		else
			echo "Nothing similar to value in list of properties for device."
		fi
		;;
	magic)
		get_trackpad
		;;
	wizard)
		id="$(xinput --list | grep -Eo '[a-zA-Z].*' | rofi 'Select device' | grep -P --only-matching 'id=\d+' | cut -d= -f2)"
		prop="$(get_props | rofi 'Select a property')"
		if [ -n "$prop" ]; then
			propId="$(echo $prop | grep -P --only-matching "\(\d+\)" | tr -d '()')"
			if [ -n "$propId" ]; then
				prettyName="$(echo $prop | sed 's/ (.*//g')"
				value="$(get_options | rofi "Set '$prettyName' to what?")"
				setProperty "$propId" "$value"
			fi
		else
			echo You chose nothing
		fi
		;;
	esac
	shift
done
