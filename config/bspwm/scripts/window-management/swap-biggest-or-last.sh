#!/bin/env bash 

case $1 in 
  global)
    qualifier=""
    ;;
  *)
    qualifier=".local"
    ;;
esac

focused=$(bspc query -n focused$qualifier --nodes)
biggest=$(bspc query -n biggest$qualifier --nodes)

if [ "$focused" == "$biggest" ]; then 
  # If the bigest node is focused, swap it with the most recently focused node on this desktop
  bspc node -s older$qualifier
else
  # Otherwise, swap it with the biggest node on this desktop
  bspc node -s $biggest
  # Focus the current biggest node to add it to the history
  bspc node -f $biggest
  # Now refocus the current focused node
  bspc node -f $focused
fi
bspc node -f biggest.local
