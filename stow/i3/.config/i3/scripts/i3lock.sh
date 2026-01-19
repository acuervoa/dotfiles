#!/bin/bash

xset +dpms dpms 0 0 5

LOCK_SCREEN=$(mktemp --suffix=.png)
SCREEN_RESOLUTION=3840x1080

echo "Capturing screen to $LOCK_SCREEN"

ffmpeg -f x11grab -video_size "$SCREEN_RESOLUTION" -y -i $DISPLAY -vframes 1 -update 1 "$LOCK_SCREEN"

if [ -f "$LOCK_SCREEN" ]; then
	echo "Screenshot saved to $LOCK_SCREEN"
	magick "$LOCK_SCREEN" -blur 0x8 "$LOCK_SCREEN"
	echo "Blur applied to screenshot"
else
	echo "Failed to caputre screenshot"
fi

i3lock -i "$LOCK_SCREEN"

xset dpms 0 0 0
rm -rf "$LOCK_SCREEN"
