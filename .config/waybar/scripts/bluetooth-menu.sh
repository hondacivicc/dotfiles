#!/bin/bash
# Bluetooth rofi menu using bluetoothctl

POWERED=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')

if [ "$POWERED" = "yes" ]; then
  DEVICES=$(bluetoothctl devices 2>/dev/null | sed 's/Device //' | awk '{$1=$1; print}')

  OPTIONS="󰂲  Turn Off"
  if [ -n "$DEVICES" ]; then
    while IFS= read -r line; do
      MAC=$(echo "$line" | awk '{print $1}')
      NAME=$(echo "$line" | cut -d' ' -f2-)
      CONNECTED=$(bluetoothctl info "$MAC" 2>/dev/null | grep "Connected: yes")
      if [ -n "$CONNECTED" ]; then
        OPTIONS="$OPTIONS\n󰂱  $Name (connected)"
      else
        OPTIONS="$OPTIONS\n󰂰  $Name"
      fi
    done <<< "$DEVICES"
  fi
  OPTIONS="$OPTIONS\n󰋌  Scan / Open Terminal"

  CHOICE=$(printf "$OPTIONS" | rofi -dmenu -p "󰂯  Bluetooth" -theme-str 'window { width: 360px; }')

  case "$CHOICE" in
    *"Turn Off"*)    bluetoothctl power off ;;
    *"Terminal"*)    kitty -e bluetoothctl ;;
    *"(connected)"*)
      MAC=$(bluetoothctl devices | grep "${CHOICE##*  }" | awk '{print $2}')
      bluetoothctl disconnect "$MAC" ;;
    *)
      [ -n "$CHOICE" ] && {
        NAME="${CHOICE##*  }"
        MAC=$(bluetoothctl devices | grep "$NAME" | awk '{print $2}')
        [ -n "$MAC" ] && bluetoothctl connect "$MAC"
      }
      ;;
  esac
else
  CHOICE=$(printf "󰂯  Turn On\n󰋌  Open Terminal" | rofi -dmenu -p "󰂲  Bluetooth (off)" -theme-str 'window { width: 300px; }')
  case "$CHOICE" in
    *"Turn On"*)  bluetoothctl power on ;;
    *"Terminal"*) kitty -e bluetoothctl ;;
  esac
fi
