#!/bin/bash
# Open a live-updating sensors window in a small floating kitty terminal
kitty --class sensors-popup --title "Sensors" \
  --override font_size=6 \
  --override confirm_os_window_close=0 \
  --override background=#13131D \
  --override foreground=#c8c8c8 \
  --override background_opacity=0.92 \
  -e watch -n 1 sensors
