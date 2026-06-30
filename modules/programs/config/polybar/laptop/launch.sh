#!/usr/bin/env bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

MONITOR=$(xrandr --query | grep " connected" | cut -d" " -f1 | head -1) polybar --reload main &
