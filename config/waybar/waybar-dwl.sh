#!/usr/bin/env bash
#
# wayar-dwl.sh - display dwl tags, layout, and active title
#   Based heavily upon this script by user "novakane" (Hugo Machet) used to do the same for yambar
#   https://codeberg.org/novakane/yambar/src/branch/master/examples/scripts/dwl-tags.sh
#
# USAGE: waybar-dwl.sh MONITOR
#        "MONITOR"   is a wayland output such as "eDP-1"
#
# STYLE: Unlike "normal" waybar modules, styles (foreground, background, underline, overline) are NOT set in style.css
#        Instead, modify the pango_* variables in THIS file
#        A guide to available pango span styling can be found here: https://docs.gtk.org/Pango/pango_markup.html
#
# SELMON INDICATION: on multiple output dwl setups, the inactve monitor will display most elements in the
#                    "inactive" pango style selected. This allows the user to glance at the waybar instance
#                    and be immediately aware of which is the active output (monitor).
#
# REQUIREMENTS:
#  - inotifywait ( 'inotify-tools' on arch )
#  - Launch dwl with `dwl > ~.cache/dwltags` or change $dwl_output_filename
#
# Now the fun part
#
### Example (multi-monitor) ~/.config/waybar/config
#          - waybar-dwl.sh takes one argument: the monitor id as returned by wlr-randr -- e.g. "eDP-1"
#          - naming the module with the monitor id as a #suffix allows running multiple instances of the
#                  dwl module in, perhaps, a waybar instance on each monitor
# [
#     {
#     "output":        "DP-2",
#     "modules-left":  ["custom/dwl#DP-2"],
#     "modules-right": ["clock"],
#     "custom/dwl#DP-2": {
# 	"exec":                    "/xap/etc/waybar/waybar-dwl.sh 'DP-2'",
# 	"format":                  "{}",
# 	"return-type":             "json"
#     },
# },
#     {
#     "output":        "HDMI-A-1",
#     "modules-left":  ["custom/dwl#HDMI-A-1"],
#     "modules-right": ["clock"],
#     "custom/dwl#HDMI-A-1": {
# 	"exec":                    "/xap/etc/waybar/waybar-dwl.sh 'HDMI-A-1'",
# 	"format":                  "{}",
# 	"return-type":             "json"
#     },
# },
# ]
#

rosewater='#f5e0dc'
flamingo='#f2cdcd'
pink='#f5c2e7'
mauve='#cba6f7'
red='#f38ba8'
maroon='#eba0ac'
peach='#fab387'
yellow='#f9e2af'
green='#a6e3a1'
teal='#94e2d5'
sky='#89dceb'
sapphire='#74c7ec'
blue='#89b4fa'
lavender='#b4befe'
text='#cdd6f4'
subtext1='#bac2de'
subtext0='#a6adc8'
overlay2='#9399b2'
overlay1='#7f849c'
overlay0='#6c7086'
surface2='#585b70'
surface1='#45475a'
surface0='#313244'
base='#1e1e2e'
mantle='#181825'
crust='#11111b'

############### USER: MODIFY THESE VARIABLES ###############
readonly dwl_output_filename=/tmp/dwl-output
# Number of lables must match dwl's config.h tagcount
readonly labels=(1 2 3 4 5 6 7 8 9) 
bold="font-face:"
pango_tag_active="<span overline='single' overline_color='$text'>" # Pango span style for 'active' tags
pango_tag_default="<span                             foreground='$overlay0'>" # Pango span style for 'default' tags
pango_tag_selected="<span                            foreground='$mauve'>" # Pango span style for 'selected' tags
pango_tag_urgent="<span                              background='$peach'>" # Pango span style for 'urgent' tags
pango_layout="<span                                  foreground='$mauve'>" # Pango span style for 'layout' character
pango_title="<span                                   foreground='$mauve'>" # Pango span style for 'title' monitor
pango_inactive="<span                                foreground='$overlay0'>" # Pango span style for elements on an INACTIVE monitor
############### USER: MODIFY THESE VARIABLES ###############

dwl_log_lines_per_focus_change=7 # This has changed several times as dwl has developed and may not yet be rock solid
full_components_list=( `seq 0 $(( ${#labels[@]} - 1 ))` "layout" "title" ) # (1, 2, ... length_of_$labels) + "layout" + "title"
monitor="${1}"

_cycle() {
    output_text=""
    # Render some components in $pango_inactive if $monitor is not the active monitor
    if [[ "${selmon}" = 0 ]]; then
	local pango_tag_default="${pango_inactive}"
	local pango_layout="${pango_inactive}"
	local pango_title="${pango_inactive}"
    fi

    for component in "${full_components_list[@]}"; do
	case "${component}" in
	    # If you use fewer than 9 tags, reduce this array accordingly
	    [012345678])
		mask=$((1<<component))
		tag_text=${labels[component]}
		# Wrap component in the applicable nestable pango spans
		if (( "${activetags}"   & mask )) 2>/dev/null; then tag_text="${pango_tag_active}${tag_text}</span>"; fi
		if (( "${urgenttags}"   & mask )) 2>/dev/null; then tag_text="${pango_tag_urgent}${tag_text}</span>"; fi
		if (( "${selectedtags}" & mask )) 2>/dev/null; then tag_text="${pango_tag_selected}${tag_text}</span>"
		else
			tag_text="${pango_tag_default}${tag_text}</span>"
		fi
		output_text+="${tag_text}  "
		;;
	    layout)
		    output_text+="${pango_layout}${layout} </span>"
		;;
	    title)
		    output_text+="${pango_title}${title}</span>"
		;;
	    *)
		output_text+="?" # If a "?" is visible on this module, something happened that shouldn't have happened
		;;
	esac
    done
}

while [[ -n "$(pgrep waybar)" ]] ; do
    [[ ! -f "${dwl_output_filename}" ]] && printf -- '%s\n' \
				    "You need to redirect dwl stdout to ~/.cache/dwltags" >&2

    # Get info from the file
    dwl_latest_output_by_monitor="$(grep  "${monitor}" "${dwl_output_filename}" | tail -n${dwl_log_lines_per_focus_change})"
    title="$(echo   "${dwl_latest_output_by_monitor}" | grep '^[[:graph:]]* title'  | cut -d ' ' -f 3- )"
    title="${title//\"/“}" # Replace quotation - prevent waybar crash
    title="${title//\&/+}" # Replace ampersand - prevent waybar crash
    layout="$(echo  "${dwl_latest_output_by_monitor}" | grep '^[[:graph:]]* layout' | cut -d ' ' -f 3- )"
    selmon="$(echo  "${dwl_latest_output_by_monitor}" | grep 'selmon' | cut -d ' ' -f 3)"

    # Get the tag bit mask as a decimal
    activetags="$(  echo "${dwl_latest_output_by_monitor}" | grep '^[[:graph:]]* tags' | awk '{print $3}')"
    selectedtags="$(echo "${dwl_latest_output_by_monitor}" | grep '^[[:graph:]]* tags' | awk '{print $4}')"
    urgenttags="$(  echo "${dwl_latest_output_by_monitor}" | grep '^[[:graph:]]* tags' | awk '{print $6}')"

    _cycle
    printf -- '{"text":"%s"}\n' "${output_text}"

    # 60-second timeout keeps this from becoming a zombified process when waybar is no longer running
    inotifywait -t 60 -qq --event modify "${dwl_output_filename}"
done

