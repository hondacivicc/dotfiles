#!/usr/bin/env bash

W1_DIR="$HOME/.config/wallpapers/wallpaper1"
W2_DAY_DIR="$HOME/.config/wallpapers/wallpaper2/day"
W2_NIGHT_DIR="$HOME/.config/wallpapers/wallpaper2/night"
STATE_FILE="$HOME/.config/hypr/.wallpaper-mode"
INDEX_FILE="$HOME/.config/hypr/.wallpaper-index"
MONITOR=$(hyprctl monitors -j | grep -m1 '"name"' | awk -F'"' '{print $4}')

get_images() {
    find "$1" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort
}

get_w2_dir() {
    local hour
    hour=$(date +%-H)
    if (( hour >= 6 && hour < 18 )); then
        echo "$W2_DAY_DIR"
    else
        echo "$W2_NIGHT_DIR"
    fi
}

apply_wallpaper() {
    local img="$1"
    awww img --outputs "$MONITOR" --transition-type fade --resize crop "$img"
}

case "$1" in
  stop)
    pkill -f "wallpaper-daemon.sh"
    ;;
  init)
    echo "1" > "$STATE_FILE"
    echo "0" > "$INDEX_FILE"
    mapfile -t imgs < <(get_images "$W1_DIR")
    apply_wallpaper "${imgs[0]}"
    ;;
  next)
    mode=$(cat "$STATE_FILE" 2>/dev/null || echo "1")
    index=$(cat "$INDEX_FILE" 2>/dev/null || echo "0")
    if [[ "$mode" == "1" ]]; then
        mapfile -t imgs < <(get_images "$W1_DIR")
    else
        mapfile -t imgs < <(get_images "$(get_w2_dir)")
    fi
    count=${#imgs[@]}
    next=$(( (index + 1) % count ))
    echo "$next" > "$INDEX_FILE"
    apply_wallpaper "${imgs[$next]}"
    ;;
  set1)
    echo "1" > "$STATE_FILE"
    echo "0" > "$INDEX_FILE"
    mapfile -t imgs < <(get_images "$W1_DIR")
    apply_wallpaper "${imgs[0]}"
    ;;
  set2)
    echo "2" > "$STATE_FILE"
    echo "0" > "$INDEX_FILE"
    mapfile -t imgs < <(get_images "$(get_w2_dir)")
    apply_wallpaper "${imgs[0]}"
    ;;
esac
