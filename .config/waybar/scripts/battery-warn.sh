#!/bin/bash
# Battery warning notification — run once at login via exec-once

NOTIFIED=0

while true; do
    CAPACITY=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    STATUS=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || cat /sys/class/power_supply/BAT0/status 2>/dev/null)

    if [ "$STATUS" != "Charging" ] && [ "$STATUS" != "Full" ]; then
        if [ "$CAPACITY" -le 20 ] && [ "$NOTIFIED" -eq 0 ]; then
            notify-send -u critical -i battery-low "Low Battery" "${CAPACITY}% remaining — plug in your charger"
            NOTIFIED=1
        elif [ "$CAPACITY" -gt 20 ]; then
            NOTIFIED=0
        fi
    else
        NOTIFIED=0
    fi

    sleep 60
done
