#!/bin/bash


TMPDIR=/home/emchap4/scripts/vim/tmp
TMPFILE=$TMPDIR/latex.tex

# Go to dir
cd $TMPDIR

# Open TeX file
/usr/bin/x-terminal-emulator -e vim $TMPFILE

# Wait until file is exited
until [ -f $TMPFILE ]
do
    sleep 1
done

# Compile LaTeX into PDF
xelatex -interaction=nonstopmode $TMPFILE

#Convert to png
pdftoppm $TMPDIR/latex.pdf $TMPDIR/image -png

#Copy to clipboard
xclip -selection clipboard -t image/png -i $TMPDIR/image-1.png

# Cleanup
rm $TMPDIR/image*
rm $TMPDIR/latex.*

