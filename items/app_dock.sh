#!/bin/bash

# Simple App Dock Configuration
source "$HOME/.config/sketchybar/variables.sh"

# Add updater item that will manage the app dock
sketchybar --add item app_dock.updater left \
           --set app_dock.updater \
                 drawing=off \
                 update_freq=5 \
                 script="$PLUGIN_DIR/app_dock.sh" \
           --subscribe app_dock.updater front_app_switched space_change system_woke