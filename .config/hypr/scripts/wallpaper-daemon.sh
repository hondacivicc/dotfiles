#!/usr/bin/env bash

# Wait for hyprpaper to be ready
sleep 3

# Auto-cycle wallpaper every 15 minutes
while true; do
    sleep 900
    ~/.config/hypr/scripts/wallpaper.sh next
done
