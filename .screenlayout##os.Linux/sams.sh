#!/bin/sh
xrandr --output eDP-1 --primary --mode 1920x1200 --pos 2560x449 --rotate normal \
       --output HDMI-1 --off \
       --output DP-2 --mode 2560x1080 --pos 0x0 --rotate normal \
       --output DP-1 --off \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-5 --off \
       --output DP-6 --off

bash ~/.config/polybar/launch.sh
