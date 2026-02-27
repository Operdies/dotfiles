#!/usr/bin/env bash

# This sandbox is not designed to be bullet proof. The only goal is to prevent
# an agent from doing something wild like installing new tools outside its
# working directory, modifying dotfiles, reading secrets, doing weird things
# with git, etc.

# sandboxing reference: https://reverse.put.as/wp-content/uploads/2011/09/Apple-Sandbox-Guide-v1.0.pdf

# Prevent dotnet from using a compilation server.
# This causes weird issues when compilation servers are shared between agents.
export UseSharedCompilation=false
cmd="opencode"

case "$1" in
  "")
    ;;
  *)
    cmd=("$@")
esac

workdir="$(pwd)"
sandbox-exec -f <(cat << EOF
(version 1)
(allow default)
(deny file-write* 
  (regex "^/")
  (regex "^${workdir}/.git"))
(allow file-write* 
  (regex "^/dev")
  (regex "^/tmp")
  (regex "^/private")
  (regex "^${HOME}/.local/share/opencode")
  (regex "^${HOME}/.local/state/opencode")
  (regex "^${HOME}/.config/opencode")
  (regex "^${HOME}/.cache/opencode")
  (regex "^${HOME}/.nuget")
  (regex "^${workdir}"))
(deny file* (regex "^${HOME}/.ssh"))
EOF) ${cmd[@]}
