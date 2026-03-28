#!/usr/bin/env bash

# This sandbox is not designed to be bullet proof. The only goal is to prevent
# an agent from doing something wild like installing new tools outside its
# working directory, modifying dotfiles, reading secrets, doing weird things
# with git, etc.

# sandboxing reference: https://reverse.put.as/wp-content/uploads/2011/09/Apple-Sandbox-Guide-v1.0.pdf

# debug permissions with:
# sudo log stream --predicate 'process == "kernel" AND eventMessage CONTAINS "Sandbox"'

# Disable claude update notifications -- who cares!!
export DISABLE_AUTOUPDATER=1

# Prevent dotnet from using a compilation server.
# This causes weird issues when compilation servers are shared between agents.
export UseSharedCompilation=false
cmd="opencode"
sandbox_config="code-mode"

while ! test -z "$1"; do
  case "$1" in
    "")
      ;;
    "--")
      shift
      cmd=("$@")
      break
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
    -*)
      echo "unrecognized option $1"
      exit 1
      ;;
    *)
      cmd=("$@")
      break
      ;;
  esac
  shift
done

block-docker() {
  cat << EOF
(deny network*                                             ; block docker access since this is a trivial root sandbox escape
  (literal "/var/run/docker.sock")
  (literal "/private/var/run/docker.sock")
  (literal "${HOME}/.docker/run/docker.sock"))
EOF
}

chat-mode() {
  binary="$(realpath $(command which ${cmd[0]}))"
  workdir="$(pwd)"
  cat << EOF
(version 1)
(allow default)                                            ; by default, allow everything.
                                                           ; It would be better to deny everything by default,
                                                           ; and explicitly enable required features,
                                                           ; but that is not really practical.

(deny mach-lookup                                          ; deny system resources, such as the keyring. (gh auth)
  (global-name "com.apple.SecurityServer"))                ; keyring. This is used by claude-code, but it has fallback handling after logging in without keyring access.


(deny file-write* (regex "^/"))                            ; deny writing all files by default.

(allow file-write*  file-read*
  (regex "^/dev")
  (regex "^/var")                                          ; temp files
  (regex "^/tmp")                                          ; temp files
  (regex "^/private")                                      ; temp files

  (regex "^${HOME}/.claude")                               ; claude config
  (regex "^${HOME}/.claude.json")                          ;

  (regex "^${HOME}/.cache")                                ; cache folders must be writable for some tools
  (regex "^${HOME}/Library/Caches")                        ; such as lua_lsp to work correctly

  (regex "^${HOME}/.local/share/opencode")                 ; opencode config
  (regex "^${HOME}/.local/state/opencode")                 ;
  (regex "^${HOME}/.config/opencode")                      ;
  (regex "^${HOME}/.cache/opencode"))                      ;
(allow file-read* (regex "^${workdir}"))
; rule merging is a bit weird. If two rules match similar patterns,
; presedence is sometimes decided by granularity; for example file-read* is more specific than file*, so file-read* might win.
; to reduce the risk other rules add read in .ssh, we explicitly deny read* and write* in addition to file*
(deny file* (regex "^${HOME}/.ssh"))                       ; deny reading / writing ssh keys
(deny file-read* (regex "^${HOME}/.ssh"))                  ; deny reading / writing ssh keys
(deny file-write* (regex "^${HOME}/.ssh"))                 ; deny reading / writing ssh keys
(allow file-read* (literal "${HOME}/.ssh/known_hosts"))    ; podman needs read known hosts to function
EOF
  block-docker
}

code-mode() {
  workdir="$(pwd)"
  chat-mode
  cat << EOF
(allow file-write* 
  (regex "^${HOME}/.nuget")                 ; nuget cache. This is a potential attack vector since nuget packages can later be executed outside the sandbox, but it is impractical to deny.
  (regex "^${workdir}"))
EOF
}

exec sandbox-exec -f <(${sandbox_config}) ${cmd[@]}
