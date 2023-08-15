#!/bin/env bash 

this="$(dirname "$0")"
for mac in $(cat /sys/class/net/*/address); do
  cfg_dir="$this/$mac"
  if [ -d "$cfg_dir" ]; then 
    for file in "$cfg_dir"/* ; do 
      dunstify sourcing $file 
      source $file
    done
  fi
done
