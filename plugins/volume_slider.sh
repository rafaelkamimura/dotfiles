#!/bin/bash

# Volume slider functionality
VOLUME=$INFO
osascript -e "set volume output volume $VOLUME"
sketchybar --set volume icon.highlight_color=0xffeed49f \
                       --set volume.slider slider.percentage=$VOLUME