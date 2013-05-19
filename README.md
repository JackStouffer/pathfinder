Pathfinder
==========

Pathfinder is a simple rougelike written in Lua using the Love2d framework. This project is a work in progress and likely will be forever. Expect bugs and random quirks.

The actual release is in the stable branch which includes all of the binary files. If you are feeling adventurous you can download the binary files and add them to this code, but the stability is not likely.

Build Instructions
------------------
Just to be clear, **This branch does not contain the binary files**, trying to build this without them will result in the program crashing when trying to open it.

The love app is needed to run this which can be downloaded here: http://love2d.org/#download

###Windows###
You must select all of the files and folders in the directory and then compress them into a zip. This zip must NOT contain the pathfinder/ directory and must have the files as the top level. Then rename the extension from .zip to .love. then double click the .love file.

###*inx OSes###
Navigate to the directory in the terminal and type this in
```
zip -9 -q -r pathfinder.love .
```
and double click the .love file.