#!/bin/bash

# $1 - the class name
# $2 - the image name

PREVWORKSPACE=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | cut -c1)
IMAGEPATH=~/projects/website/eric-chapdelaine.github.io/notes/$1/$2

cp ~/.config/inkscape-figures/template.svg $IMAGEPATH.svg

~/scripts/vim/just_ink.sh $IMAGEPATH.svg

inkscape --export-type="png" --export-dpi=1000 $IMAGEPATH.svg 
