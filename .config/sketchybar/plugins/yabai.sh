#!/bin/bash

# Yabai integration
if [ "$1" = "create_space" ]; then
  yabai -m space --create
  sketchybar --trigger windows_on_spaces
fi