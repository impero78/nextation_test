#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 [normal|left|right|inverted]"
    exit 1
fi

ORIENTATION="$1"
COORDS=""

if [ "$ORIENTATION" = "left" ]; then
  COORDS="0 -1 1 1 0 0 0 0 1"
elif [ "$ORIENTATION" = "right" ]; then
  COORDS="0 1 0 -1 0 1 0 0 1"
elif [ "$ORIENTATION" = "inverted" ]; then
  COORDS="-1 0 1 0 -1 1 0 0 1"
elif [ "$ORIENTATION" = "normal" ]; then
  COORDS="0 0 0 0 0 0 0 0 0"
else
  echo "Invalid mode. Please specify one of the following: normal, left, right, inverted"
  exit 1
fi

xrandr -o "$ORIENTATION"

while IFS= read -r line; do
    # Check if the line contains "slave pointer"
    if [[ $line == *"slave  pointer"* ]]; then
        # Extract the id
        ID=$(echo "$line" | grep -oP 'id=\K\d+')
        xinput set-prop "$ID" --type=float "Coordinate Transformation Matrix" $COORDS
    fi
done <<< "$(xinput list)"
