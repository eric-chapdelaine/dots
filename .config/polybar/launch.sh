#!/bin/bash

#Kill other polybars
killall -q polybar

#wait until thats done
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

#launch polybar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload example &
  done
else
  polybar --reload example &
fi

echo "Polybar launched..."
