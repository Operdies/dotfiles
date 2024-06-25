#!/bin/sh

capscontrol() {
	# map ctrl tab to escape
	xcape -t 280
	# map caps to ctrl
	setxkbmap us -variant altgr-intl -option ctrl:nocaps
}

capsescape() {
	setxkbmap us -variant altgr-intl -option caps:escape
}


capsescape

# Key repeat after 200ms, 30 times per second 
xset r rate 250 30
