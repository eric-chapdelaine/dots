#!/bin/bash

/usr/bin/x-terminal-emulator -e vim --nofork ./doc
#gvim --nofork ~/test/doc

until [ -f ./doc ]
do
    sleep 1
done
echo "File Found"

cat ./doc | xclip -selection clipboard
rm ./doc
