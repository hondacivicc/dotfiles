#!/usr/bin/env bash

HYPR_DIR="$HOME/.config/hypr"

rofi_menu() {
  local -n _arr=$1
  local longest=0
  for item in "${_arr[@]}"; do
    ((${#item} > longest)) && longest=${#item}
  done
  local width=$((longest * 11 + 50))
  local height=$((${#_arr[@]} * 40 + 20))
  printf '%s\n' "${_arr[@]}" | rofi -dmenu \
    -lines ${#_arr[@]} \
    -theme-str "inputbar {enabled: false;} window {width: ${width}px; height: ${height}px;} listview {margin: 8px 0 0 0;}" \
    -no-custom -format s
}

options=(
  "Apps"
  "Edit Configs"
  "Install"
  "Power"
)

if [[ "$1" == "--install" ]]; then
  chosen="Install"
else
  chosen=$(rofi_menu options)
fi

case "$chosen" in
"Apps")
  rofi -show drun
  ;;
"Edit Configs")
  edit_options=(
    "Hyprland.conf"
    "Keybinds"
    "Look & Feel"
    "Windowrules"
    "Autostart"
    "Env"
    "Input"
  )
  file=$(rofi_menu edit_options)
  case "$file" in
  "Hyprland.conf") alacritty -e nvim "$HYPR_DIR/hyprland.conf" ;;
  "Keybinds") alacritty -e nvim "$HYPR_DIR/conf/keybinds.conf" ;;
  "Look & Feel") alacritty -e nvim "$HYPR_DIR/conf/look-and-feel.conf" ;;
  "Windowrules") alacritty -e nvim "$HYPR_DIR/conf/windowrules.conf" ;;
  "Autostart") alacritty -e nvim "$HYPR_DIR/conf/autostart.conf" ;;
  "Env") alacritty -e nvim "$HYPR_DIR/conf/env.conf" ;;
  "Input") alacritty -e nvim "$HYPR_DIR/conf/input.conf" ;;
  esac
  ;;
"Install")
  install_options=(
    "Pacman"
    "AUR"
    "Web App"
  )
  source=$(rofi_menu install_options)
  case "$source" in
  "Pacman")
    pkg=$(pacman -Slq 2>/dev/null | sort -u | rofi -dmenu \
      -theme-str 'window {width: 400px;}' \
      -format s)
    [[ -n "$pkg" ]] && alacritty --class pkg-install -e bash -c "paru -S --noconfirm $pkg; echo; read -p 'Press Enter to close...'"
    ;;
  "AUR")
    query=$(rofi -dmenu \
      -theme-str 'window {width: 400px;}' \
      -p "Search AUR:" \
      -format s < /dev/null)
    if [[ -n "$query" ]]; then
      pkg=$(paru -Ss --aur "$query" 2>/dev/null \
        | awk 'NR%2==1 {split($1,a,"/"); print a[2]}' \
        | rofi -dmenu \
          -theme-str 'window {width: 400px;}' \
          -format s)
      [[ -n "$pkg" ]] && alacritty --class pkg-install -e bash -c "paru -S --noconfirm $pkg; echo; read -p 'Press Enter to close...'"
    fi
    ;;
  "Web App")
    alacritty --class pkg-install -e bash -c "mkwebapp"
    ;;
  esac
  ;;
"Power")
  ~/.config/hypr/scripts/powermenu.sh
  ;;
esac
