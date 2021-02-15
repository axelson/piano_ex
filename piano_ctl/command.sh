#!/bin/bash

CONFIG_DIR="${XDG_CONFIG_HOME:-~/.config}/pianobar"

PIPE_FILE="${CONFIG_DIR}/input.pipe"
PID_FILE="${CONFIG_DIR}/piano_ctl_pid"

PID=$(cat "$PID_FILE")

if ps "$PID" > /dev/null; then
    echo "$1" >> "$PIPE_FILE"
    echo "$(</dev/stdin)" >> "$PIPE_FILE"
fi

