#!/usr/bin/env bash

# This sandbox is not designed to be bullet proof. The only goal is to prevent
# an agent from doing something wild like installing new tools outside its
# working directory, modifying dotfiles, reading secrets, doing weird things
# with git, etc.

# sandboxing reference: https://reverse.put.as/wp-content/uploads/2011/09/Apple-Sandbox-Guide-v1.0.pdf

# debug permissions with:
# Sudo log stream --predicate 'process == "kernel" AND eventMessage CONTAINS "Sandbox"'

# Prevent dotnet from using a compilation server.
# This causes weird issues when compilation servers are shared between agents.
export UseSharedCompilation=false
cmd="opencode"
sandbox_config="code-mode"

while ! test -z "$1"; do
  case "$1" in
    "")
      ;;
    "--mode")
      shift
      case "$1" in 
        "code")
          sandbox_config="code-mode"
          ;;
        "chat")
          sandbox_config="chat-mode"
          ;;
        *)
          echo "Unrecognized mode: $1. Only code and chat is supported."
          exit 1
          ;;
      esac
      ;;
    *)
      cmd=("$@")
      break
      ;;
  esac
  shift
done

chat-mode() {
  binary="$(realpath $(command which ${cmd[0]}))"
  workdir="$(pwd)"
  cat << EOF
(version 1)
(allow default)                             ; by default, allow everything.
                                            ; It would be better to deny everything by default,
                                            ; and explicitly enable required features,
                                            ; but that is not really practical.

(deny mach-lookup                           ; deny system resources, such as the keyring. (gh auth)
  (global-name "com.apple.SecurityServer")) ; keyring


(deny file-write* (regex "^/"))             ; deny writing all files by default.

(allow file* 
  (regex "^/dev")
  (regex "^/var")                           ; temp files
  (regex "^/tmp")                           ; temp files
  (regex "^/private")                       ; temp files

  (regex "^${HOME}/.claude")                ; claude config
  (regex "^${HOME}/.claude.json")           ;

  (regex "^${HOME}/.local/share/opencode")  ; opencode config
  (regex "^${HOME}/.local/state/opencode")  ;
  (regex "^${HOME}/.config/opencode")       ;
  (regex "^${HOME}/.cache/opencode"))       ;
(allow file-read* (regex "^${workdir}"))

(deny file* (regex "^${HOME}/.ssh"))        ; deny reading / writing ssh keys
EOF
}

code-mode() {
  workdir="$(pwd)"
  chat-mode
  cat << EOF
(allow file-write* 
  (regex "^${HOME}/.nuget")                 ; nuget cache
  (regex "^${workdir}"))
EOF
}

sandbox-exec -f <(${sandbox_config}) ${cmd[@]}
