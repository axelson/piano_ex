#!/bin/bash

#FILE=/home/jason/dev/piano_ex/input.pipe
FILE=/Users/jason/dev/piano_ex/input.pipe
#FILE="/Users/jason/dev/piano_ex/research/examples/$1-$(date '+%H:%M:%S:%s').txt"
#echo "$1" >> $FILE
echo -e "$1\n$(</dev/stdin)\nEND_STREAM" >> $FILE
