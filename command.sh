#!/bin/bash

FILE=/home/jason/dev/piano_ex/input.pipe
echo "$1" >> $FILE
echo "$(</dev/stdin)" >> $FILE
