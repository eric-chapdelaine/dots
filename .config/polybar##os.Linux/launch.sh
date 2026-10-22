#!/usr/bin/env bash

# kill and wait
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

PRIMARY=$(xrandr --query | grep " primary" | cut -d" " -f1)

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    # in the case of thinkpad + monitor, thinkpad screen is primary
    # but for now, i will have the same behavior for both
    if [ "$m" == "$PRIMARY" ]; then
      MONITOR=$m polybar --reload example & 
    else
      MONITOR=$m polybar --reload example &
    fi
  done
else
  polybar --reload example &
fi
