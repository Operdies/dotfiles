#!/bin/bash 

echo "Please click the window"
win=$(xwininfo)

winId=$(echo "$win" | grep "Window id:" | grep -o "0x[^ ]\+")
echo "Got window with ID $winId"

width=$(echo "$win" | grep "Width:" | cut -d: -f2)
height=$(echo "$win" | grep "Height:" | cut -d: -f2)

echo "It has dimensions $width x $height"

newWidth=$1 
newHeight=$2

echo "Resizing to $newWidth x $newHeight"

bspc node $winId --resize right $((newWidth - width)) 0
bspc node $winId --resize bottom 0 $((newHeight - height))

