export XSESSION_PID="$$"
sh "$HOME/.config/dwm/startup.sh" dwm
while true; do
  "$HOME/repos/dotfiles/src/dwm/dwm" 2>> "/tmp/dwm$DISPLAY" || sleep 1
done

# vim: set et sw=2 sts=2 tw=78 ft=sh:
