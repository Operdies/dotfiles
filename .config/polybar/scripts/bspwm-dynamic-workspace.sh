#!/bin/bash
function GetWindows {
  bspc wm -d | yq '.monitors[] | 
    .desktops[] | 
    .root | 
    [.. | select(has("client"))][] | 
    .client | select(has("className")) | 
    [ (parent | parent | parent | .name) + "
" + .className ][]'
  # Here we traverse the parent stack to get back to the name of the workspace
}

function GetIcon {
  local class="$1"
  case $class in 
    [Ff]irefox)
      echo -ne ""
      ;;
    looking-glass-client)
      echo -ne "⊞"
      ;;
    [Aa]lacritty)
      echo -ne ""
      ;;
    [Cc]hrome|[Cc]hromium)
      echo -ne ""
      ;;
    [Dd]iscord)
      echo -ne ""
      ;;
    [Ss]potify)
      echo -ne ""
      ;;
    [Tt]hunar)
      echo -ne ""
      ;;
    *)
      echo -ne $class
      ;;
  esac
}

function FocusedWorkspace {
  bspc query -D  --names -d .focused
}

function Iconography {
  local focused="$(FocusedWorkspace)"
  local windows=($(GetWindows))
  local current=""

  for ((i=0; i < ${#windows[@]}; i+=2)); do
    local workspace=${windows[i]}
    local class=${windows[i+1]}

    if [ ! "$current" = "$workspace" ]; then
      if [ ! -z "$current" ]; then 
        echo -ne "]%{A} "
      fi

      echo -ne "%{A1:bspc desktop -f $workspace:}"

      if [ "$workspace" = "$focused" ]; then
        echo -ne "%{F#aaf}"
      else
        if [ "$current" = "$focused" ]; then 
          echo -ne "%{F-}"
        fi
      fi
      echo -ne "$workspace ["
    fi
    current="$workspace"
    echo -ne " $(GetIcon $class) "
  done
  echo "]"
}

Iconography
