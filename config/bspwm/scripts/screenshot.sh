#!/bin/bash

# options to be displayed
option0="screen"
option1="area"
option2="window"

# options to be displyed
options="$option0\n$option1\n$option2"

scrot () {
  command scrot $@ '/tmp/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f; mv $f ~/Pictures/'
}

selected="$(echo -e "$options" | rofi -lines 3 -dmenu -p "scrot")"
case $selected in
    $option0)
        cd ~/Pictures/ && sleep 1 && scrot;;
    $option1)
        cd ~/Pictures/ && scrot -s;;
    $option2)
        cd ~/Pictures/ && sleep 1 && scrot -u;;
esac

