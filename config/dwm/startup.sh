# Fix various java issues. Taken from https://wiki.gentoo.org/wiki/Dwm#Fix_Java_application_misbehaving
# Primarily for ghidra and jebtrains IDEs
fix_java() {
	export _JAVA_AWT_WM_NONREPARENTING=1
	export AWT_TOOLKIT=MToolkit
	wmname LG3D
}

fix_java

notify() {
	msg="$*"
	notify-send -u normal -t 2000 bspwmrc "$msg" &
}

error() {
	msg="$*"
	notify-send -u critical bspwmrc "$msg" &
}

has() {
	command -v "$1"
}

num_monitors() {
	xrandr --listactivemonitors | head -n 1 | cut -d':' -f2 | xargs
}

if has redshift; then
	pgrep -x redshift >/dev/null || redshift &
fi


# dex -a -s ~/.config/autostart/
# elevation requests
dex /etc/xdg/autostart/xfce-polkit.desktop
# blueman-applet
dex /etc/xdg/autostart/blueman.desktop

# the firewall-applet in /etc/xdg/autostart/firewall-applet.desktop
# does not check if it is already running and will launch new instances.
# This hack just kills them all and starts a new one
# pkill firewall-applet
# firewall-applet &
# Network Applet

# nm-applet --indicator &
# if has picom; then
# 	picom -b --config ~/.config/picom.conf &
# fi

# keyboard layout + caps mapping
~/.config/dwm/configurekeyboard.sh

config_dir="sxhkd"
if [ "$1" == dwm ]; then
	config_dir="dwm"
fi

rhkd -c "$HOME/.config/$config_dir/sxhkdrc" &
rhkd-whichkey -c "$HOME/.config/$config_dir/sxhkdrc" &
(sleep 1; bash "$HOME/.config/$config_dir/bash_config.bash" --quiet) &

~/repos/dotfiles/src/xautobacklight/xautobacklight --initial-state 0 --timeout 5 --led-file "/sys/class/leds/asus::kbd_backlight/brightness" &

