#!/bin/bash

# $1 - the class name
# $2 - the image name

PREVWORKSPACE=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | cut -c1)
IMAGEPATH=~/projects/website/eric-chapdelaine.github.io/notes/$1/$2

cp ~/.config/inkscape-figures/template.svg $IMAGEPATH.svg
i3-msg workspace number 11

python3 ~/.config/inkscape-shortcut-manager/inkscape-shortcut-manager/main.py & echo "$!" > /tmp/ink.pid

inkscape $IMAGEPATH.svg

while pgrep -u $UID -x inkscape >/dev/null; do sleep 1; done

inkscape --export-type="png" --export-dpi=1000 $IMAGEPATH.svg 

kill -9 $(cat /tmp/ink.pid) > /dev/null

i3-msg workspace number $PREVWORKSPACE

rm /tmp/ink.pid
