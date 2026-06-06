#!/usr/bin/env bash
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    if xrandr --query | grep -A 10 "^$m connected" | grep -q "\*"; then
        MONITOR=$m polybar --reload main &
    fi
done
