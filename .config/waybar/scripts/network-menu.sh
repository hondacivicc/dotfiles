#!/bin/bash
# Rofi network manager using nmcli

ACTIVE=$(nmcli -t -f NAME,TYPE,STATE connection show --active | grep -i wireless | head -1 | cut -d: -f1)
STATUS=$(nmcli networking connectivity)

# Build header
if [ -n "$ACTIVE" ]; then
  SIGNAL=$(nmcli -t -f IN-USE,SIGNAL device wifi | grep '^\*' | cut -d: -f2)
  HEADER="󰤨  $ACTIVE (${SIGNAL}%)"
else
  HEADER="󰤮  Not connected"
fi

# Scan and list available networks
NETWORKS=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list 2>/dev/null \
  | grep -v '^:' \
  | sort -t: -k2 -rn \
  | awk -F: '!seen[$1]++ && $1!="" {
      signal = $2+0
      if (signal >= 75) icon = "󰤨"
      else if (signal >= 50) icon = "󰤥"
      else if (signal >= 25) icon = "󰤢"
      else icon = "󰤟"
      lock = ($3 != "--" && $3 != "") ? " 󰌾" : ""
      printf "%s  %s%s (%s%%)\n", icon, $1, lock, $2
    }')

OPTIONS="$HEADER\n─────────────────────\n$NETWORKS\n─────────────────────\n󰖩  Disconnect\n󰒓  Network Settings"

CHOICE=$(printf "$OPTIONS" | rofi -dmenu \
  -p "  Network" \
  -theme-str '
    window   { width: 380px; }
    listview { lines: 12; }
  ')

[ -z "$CHOICE" ] && exit

SSID=$(echo "$CHOICE" | sed 's/^[^ ]*  //' | sed 's/ 󰌾.*//' | sed 's/ ([0-9]*%)//' | xargs)

case "$CHOICE" in
  *"Disconnect"*)
    nmcli connection down "$ACTIVE" 2>/dev/null
    notify-send "Network" "Disconnected from $ACTIVE"
    ;;
  *"Network Settings"*)
    kitty --class network-settings -e nmtui
    ;;
  *"Not connected"*|*"─────"*)
    exit
    ;;
  *)
    # Try to connect — use saved profile first, else prompt password via kitty
    SAVED=$(nmcli -t -f NAME connection show | grep -Fx "$SSID")
    if [ -n "$SAVED" ]; then
      nmcli connection up "$SSID" 2>/dev/null \
        && notify-send "Network" "Connected to $SSID" \
        || notify-send "Network" "Failed to connect to $SSID"
    else
      kitty --class network-settings -e bash -c \
        "nmcli --ask device wifi connect '$SSID'; echo 'Press Enter to close'; read"
    fi
    ;;
esac
