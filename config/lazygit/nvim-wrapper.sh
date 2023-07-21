#!/bin/env bash

# Open with nvr if we are currently running within a nvim session, otherwise create a new session

if [ -n "$NVIM" ]; then
  nvr -l "$@"
else
  nvim "$@"
fi
