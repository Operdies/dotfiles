#!/bin/bash

log2() {
  echo "l($1) / l(2)" | bc -l
}

log8() {
  echo "l($1) / l(8)" | bc -l
}

# Raise $2 to the $1th power where $1 can be a fractional number
exp() {
  a="$1"
  b="$2"
  echo "e($b*l($a))" | bc -l
}

# Conver the volume level from an exponential scale to a linear scale 
# e.g. 2^log8(k)
# This is the inverse of 'toExponential'
toLinear() {
  if [ "$1" = 0 ]; then 
    echo "0"
  else
    logged=$(log8 "$1")
    exp 2 "$logged"
  fi
}

# Convert the volume level from a linear scale to an exponential scale
# e.g. 8^(log2(k))
# This is the inverse of 'toLinear'
toExponential() {
  if [ "$1" = 0 ]; then 
    echo "0"
  else 
    deexp=$(log2 "$1")
    exp 8 "$deexp"
  fi
}

# add two floating point numbers
addf() {
  echo "$1 + $2" | bc
}

# round to nearest integer
round() {
  n=$(echo "$1 + .5" | bc -l)
  echo "${n%.*}"
}

raise_volume() {
  settings="$(amixer get Master)"
  max="$(echo "$settings" | grep "Limits:" | xargs | cut -d' ' -f 5)"
  current="$(echo "$settings" | grep -m 1 "Front.*:" | xargs | cut -d' ' -f 4)"

  maxl=$(toLinear "$max")
  stepPct="$1"
  stepSize=$(echo "$stepPct * $maxl" | bc -l)
  currentl=$(toLinear "$current")
  nextl=$(addf "$stepSize" "$currentl")

  if [ -z "$nextl" ] || [[ "$nextl" == "-"* ]]; then 
    nextScaled="0"
  else 
    nextScaled=$(toExponential "$nextl")
  fi

  floored=$(round "$nextScaled")

  if [ -z "$floored" ] || [[ "$floored" == "-"* ]]; then 
    floored="0"
  fi

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
