#!/bin/bash

log2() {
  echo "l($1) / l(2)" | bc -l
}

log8() {
  echo "l($1) / l(8)" | bc -l
}

exp() {
  a="$1"
  b="$2"
  echo "e($b*l($a))" | bc -l
}

toLinear() {
  logged=$(log8 "$1")
  exp 2 "$logged"
}

toExponential() {
  deexp=$(log2 "$1")
  exp 8 "$deexp"
}

addf() {
  echo "$1 + $2" | bc
}

raise_volume() {
  settings="$(amixer get Master)"
  max="$(echo "$settings" | grep "Limits:" | xargs | cut -d' ' -f 5)"
  current="$(echo "$settings" | grep -m 1 "Front.*:" | xargs | cut -d' ' -f 4)"

  if [ "$current" = 0 ]; then 
    amixer set Master 8
    return
  fi

  maxl=$(toLinear "$max")
  stepPct="$1"
  stepSize=$(echo "$stepPct * $maxl" | bc -l)
  currentl=$(toLinear "$current")
  nextl=$(addf "$stepSize" "$currentl")
  nextScaled=$(toExponential "$nextl")
  floored=${nextScaled%.*}

  echo "Linear: ($currentl/$maxl) -> ($nextl/$maxl)"
  echo "Scaled: ($current/$max) -> ($floored/$max)"
  amixer set Master "$floored" unmute
}

case $1 in 
  inc)
    raise_volume "$2"
    ;;
  dec)
    raise_volume "-$2"
    ;;
esac
