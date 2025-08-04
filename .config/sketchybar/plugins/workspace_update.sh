#!/bin/bash

# Update all workspace-related widgets
update_all_workspaces() {
    # Update individual spaces
    for i in {1..10}; do
        sketchybar --trigger space_change --set space.$i
    done
    
    # Update workspace overview
    sketchybar --trigger windows_on_spaces
}

# Call the update function
update_all_workspaces