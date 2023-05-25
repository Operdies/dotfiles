#!/bin/env bash

MON="$1"
if [ "$(bspc query -M -m "^$MON")" = "$(bspc query -M -m focused)" ]; then
  if bspc query -D -d next.occupied.local; then
    bspc desktop -f next.occupied.local
  else
    bspc desktop -f next.local
  fi
else
	bspc monitor -f "^$MON"
fi
