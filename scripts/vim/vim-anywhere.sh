#!/bin/bash

/usr/bin/x-terminal-emulator -e vim --nofork ./vim-anywhere
#gvim --nofork ~/test/doc

until [ -f ./vim-anywhere ]
do
    sleep 1
done
echo "File Found"

cat ./vim-anywhere | xclip -selection clipboard
rm ./vim-anywhere
