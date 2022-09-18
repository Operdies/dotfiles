#!/bin/bash 

echo "Please click the window"
winId="$3"
if [ -z "$winId" ]; then 
  win=$(xwininfo)
  winId=$(echo "$win" | grep "Window id:" | grep -o "0x[^ ]\+")
  echo "Got window with ID $winId"
else 
  win=$(xwininfo -id $winId)
fi

width=$(echo "$win" | grep "Width:" | cut -d: -f2)
height=$(echo "$win" | grep "Height:" | cut -d: -f2)

echo "It has dimensions $width x $height"

newWidth=$1 
newHeight=$2

echo "Resizing to $newWidth x $newHeight"

bspc node "$winId" --resize right $((newWidth - width)) 0
bspc node "$winId" --resize bottom 0 $((newHeight - height))

echo "New size: $(bspc query -n $winId -T | yq '.client.tiledRectangle.width + "x" + .client.tiledRectangle.height')"
