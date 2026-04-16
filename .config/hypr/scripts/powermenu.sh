#!/usr/bin/env bash

options=(
  " Lock"
  " Log Out"
  " Suspend"
  " Restart"
  " Shutdown"
  " Reload Hyprland"
)

longest=0
for item in "${options[@]}"; do
  (( ${#item} > longest )) && longest=${#item}
done
width=$(( longest * 11 + 50 ))
height=$(( ${#options[@]} * 40 + 20 ))

chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu \
  -lines ${#options[@]} \
  -theme-str "inputbar {enabled: false;} window {width: ${width}px; height: ${height}px;} listview {margin: 8px 0 0 0;}" \
  -no-custom \
  -format s)

case "$chosen" in
" Lock")             hyprlock ;;
" Log Out")          hyprctl dispatch exit ;;
" Suspend")          systemctl suspend ;;
" Restart")          systemctl reboot ;;
" Shutdown")         systemctl poweroff ;;
" Reload Hyprland")  hyprctl reload ;;
esac
