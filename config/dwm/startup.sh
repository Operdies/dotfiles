# Fix various java issues. Taken from https://wiki.gentoo.org/wiki/Dwm#Fix_Java_application_misbehaving
# Primarily for ghidra and jebtrains IDEs
fix_java() {
	export _JAVA_AWT_WM_NONREPARENTING=1
	export AWT_TOOLKIT=MToolkit
	wmname LG3D
}

fix_java

# Notifications
/usr/bin/dunst &
dunstctl close-all

notify() {
	msg="$*"
	dunstify -u normal -t 2000 bspwmrc "$msg"
}

error() {
	msg="$*"
	dunstify -u critical bspwmrc "$msg"
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


# Polkit
# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# Dex
# dex -a -s /etc/xdg/autostart/:~/.config/autostart/
# dex -a -s ~/.config/autostart/
dex ~/.config/autostart/xfce-polkit-gnome-authentication-agent-1.desktop

# the firewall-applet in /etc/xdg/autostart/firewall-applet.desktop
# does not check if it is already running and will launch new instances.
# This hack just kills them all and starts a new one
# pkill firewall-applet
# firewall-applet &
# Network Applet

# nm-applet --indicator &
if has picom; then
	picom -b --config ~/.config/picom.conf &
fi

# Wallpaper
nitrogen --restore &

# Set caps = escape
# This should run before sxhkd starts so caps can be mapped to ESCAPE_KEYSYM
setxkbmap us -variant altgr-intl
setxkbmap -option caps:escape
pgrep -x rhkd || rhkd -c ~/.config/sxhkd/sxhkdrc &
pgrep -x rhkd-whichkey || rhkd-whichkey -c ~/.config/sxhkd/sxhkdrc &

# rhkd-whichkey doesn't immediately load, so we reload the config in the background
(sleep 1; ~/.config/sxhkd/bash_config.bash --quiet) &

