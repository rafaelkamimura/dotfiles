#!/bin/bash

# Test script for the new app icon system
source "$HOME/.config/sketchybar/variables.sh"

echo "=== SketchyBar Enhanced App Icon System Test ==="
echo ""

# Test apps from the current running list
test_apps=("Finder" "ghostty" "Google Chrome" "Docker Desktop" "Spotify" "System Settings")

echo "Testing icon resolution for current apps:"
echo "========================================"

for app in "${test_apps[@]}"; do
    echo ""
    echo "App: $app"
    echo "  SF Symbol preference:  $(./plugins/app_icon_system.sh "$app" false 2>/dev/null)"
    echo "  Native icon preference: $(./plugins/app_icon_system.sh "$app" true 2>/dev/null)"
    
    # Check if native extraction worked
    if SKETCHYBAR_DEBUG=1 ./plugins/app_icon_extractor.sh "$app" >/dev/null 2>&1; then
        native_path=$(./plugins/app_icon_extractor.sh "$app" 2>/dev/null)
        echo "  Native icon available:  $native_path"
    else
        echo "  Native icon available:  No"
    fi
done

echo ""
echo "Icon Cache Status:"
echo "=================="
cache_dir="$HOME/.config/sketchybar/cache/icons"
if [ -d "$cache_dir" ]; then
    echo "Cache directory: $cache_dir"
    echo "Cached icons:"
    ls -la "$cache_dir" | grep -v "^total" | grep -v "^drwx" | while read -r line; do
        echo "  $line"
    done
else
    echo "No cache directory found"
fi

echo ""
echo "=== Test Complete ==="