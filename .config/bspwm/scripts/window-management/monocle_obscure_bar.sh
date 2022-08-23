#!/bin/bash
dpad=${1:-top}
while read -ra e; do
  i=1
  for word in ${e[@]}; do 
    echo "$i ) $word"
    i=$((i+1))
  done
    if [[ ${e[3]} = monocle ]]; then
        c=hide
        ppad="-$(bspc config -m ${e[1]} ${dpad}_padding)"
    else
        c=show 
        ppad=0
    fi
    polybar-msg cmd "$c" &&
        bspc config -d ${e[2]} ${dpad}_padding $ppad
done < <(bspc subscribe desktop_focus desktop_layout)
