#!/usr/bin/env bash
pkill polybar 2>/dev/null
sleep 0.5
MONITOR=DP-2 polybar --reload main &
