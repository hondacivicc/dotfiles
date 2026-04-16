#!/bin/bash
# Power profile selector using rofi + powerprofilesctl

CURRENT=$(powerprofilesctl get)

CHOICE=$(printf "  Performance\n󰾅  Balanced\n󰌪  Power Saver" | rofi -dmenu \
  -p "⚡ Power Profile (active: $CURRENT)" \
  -theme-str 'window { width: 300px; } listview { lines: 3; }')

case "$CHOICE" in
  *"Performance"*) powerprofilesctl set performance && notify-send "Power Profile" "Switched to Performance" ;;
  *"Balanced"*)    powerprofilesctl set balanced    && notify-send "Power Profile" "Switched to Balanced" ;;
  *"Power Saver"*) powerprofilesctl set power-saver && notify-send "Power Profile" "Switched to Power Saver" ;;
esac
