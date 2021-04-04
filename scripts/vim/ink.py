#!/usr/bin/python3
import subprocess
import sys 

if __name__ == "__main__":
    classname = sys.argv[1]
    filename = sys.argv[2]
    subprocess.run(["/home/emchap4/scripts/vim/ink.sh", classname, filename], capture_output=True)

    output = f"""<div style='width: 100%' class='ui rounded images'>
<img class='ui image' src='/notes/{classname}/{filename}.png'>
</div>
"""

    print(output)
