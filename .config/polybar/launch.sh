#!/bin/bash

#Kill other polybars
killall -q polybar

#wait until thats done
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

#launch polybar
polybar example &

echo "Polybar launched..."
