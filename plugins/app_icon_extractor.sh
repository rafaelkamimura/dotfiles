#!/bin/bash

# macOS App Icon Extractor for SketchyBar
# Extracts actual app icons instead of using emoji fallbacks
# Supports multiple extraction methods with caching

source "$HOME/.config/sketchybar/variables.sh"

# Configuration
ICON_CACHE_DIR="$HOME/.config/sketchybar/cache/icons"
ICON_SIZE=64  # Target icon size for SketchyBar (will be resized to 18-24px by SketchyBar)
ICON_FORMAT="png"
MAX_CACHE_AGE_DAYS=30

# Ensure cache directory exists
mkdir -p "$ICON_CACHE_DIR"

# Function to log debug messages
debug_log() {
    if [ "${SKETCHYBAR_DEBUG:-0}" = "1" ]; then
        echo "[DEBUG] app_icon_extractor: $1" >&2
    fi
}

# Function to clean old cache files
clean_cache() {
    find "$ICON_CACHE_DIR" -name "*.png" -mtime +${MAX_CACHE_AGE_DAYS} -delete 2>/dev/null
}

# Function to get app bundle path using multiple methods
get_app_bundle_path() {
    local app_name="$1"
    local bundle_path
    
    # Method 1: Try using System Events to get bundle path
    bundle_path=$(osascript -e "
        try
            tell application \"System Events\"
                set appProcess to first application process whose name is \"$app_name\"
                set bundleId to bundle identifier of appProcess
                if bundleId is not \"\" then
                    set appPath to POSIX path of (path to application id bundleId)
                    return appPath
                end if
            end tell
        on error
        end try
        return \"\"
    " 2>/dev/null)
    
    # Clean up the path
    bundle_path=$(echo "$bundle_path" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
    
    if [ -n "$bundle_path" ] && [ -d "$bundle_path" ]; then
        debug_log "Bundle path (method 1) for '$app_name': '$bundle_path'"
        echo "$bundle_path"
        return 0
    fi
    
    # Method 2: Try direct path lookup in common locations
    local common_paths=(
        "/Applications/${app_name}.app"
        "/System/Applications/${app_name}.app"
        "/Applications/Utilities/${app_name}.app"
        "/System/Applications/Utilities/${app_name}.app"
        "/System/Library/CoreServices/${app_name}.app"
        "$HOME/Applications/${app_name}.app"
    )
    
    for path in "${common_paths[@]}"; do
        if [ -d "$path" ]; then
            debug_log "Bundle path (method 2) for '$app_name': '$path'"
            echo "$path"
            return 0
        fi
    done
    
    # Method 3: Try using mdfind to locate the app
    local found_path
    found_path=$(mdfind "kMDItemContentType == 'com.apple.application-bundle' && kMDItemDisplayName == '$app_name'" 2>/dev/null | head -1)
    
    if [ -n "$found_path" ] && [ -d "$found_path" ]; then
        debug_log "Bundle path (method 3) for '$app_name': '$found_path'"
        echo "$found_path"
        return 0
    fi
    
    debug_log "No bundle path found for '$app_name'"
    return 1
}

# Function to get app bundle icon name from Info.plist
get_bundle_icon_name() {
    local bundle_path="$1"
    local icon_name
    
    if [ ! -d "$bundle_path" ]; then
        return 1
    fi
    
    local info_plist="$bundle_path/Contents/Info.plist"
    if [ ! -f "$info_plist" ]; then
        return 1
    fi
    
    # Try to get CFBundleIconFile or CFBundleIconName
    icon_name=$(defaults read "$info_plist" CFBundleIconFile 2>/dev/null)
    if [ -z "$icon_name" ]; then
        icon_name=$(defaults read "$info_plist" CFBundleIconName 2>/dev/null)
    fi
    
    debug_log "Icon name from bundle: '$icon_name'"
    echo "$icon_name"
}

# Function to extract icon from .icns file
extract_from_icns() {
    local icns_path="$1"
    local output_path="$2"
    
    if [ ! -f "$icns_path" ]; then
        return 1
    fi
    
    debug_log "Extracting from .icns: $icns_path"
    
    # Use sips to convert .icns to .png at desired size
    if sips -s format png -Z "$ICON_SIZE" "$icns_path" --out "$output_path" >/dev/null 2>&1; then
        debug_log "Successfully extracted icon from .icns"
        return 0
    fi
    
    return 1
}

# Function to extract icon from Assets.car
extract_from_assets_car() {
    local assets_car_path="$1"
    local icon_name="$2"
    local output_path="$3"
    
    if [ ! -f "$assets_car_path" ] || [ -z "$icon_name" ]; then
        return 1
    fi
    
    debug_log "Extracting from Assets.car: $assets_car_path, icon: $icon_name"
    
    # Create temporary icns file
    local temp_icns=$(mktemp -t "app_icon_XXXXXX.icns")
    
    # Use iconutil to extract from Assets.car
    if iconutil -c icns "$assets_car_path" "$icon_name" -o "$temp_icns" >/dev/null 2>&1; then
        # Convert the .icns to .png
        if extract_from_icns "$temp_icns" "$output_path"; then
            rm -f "$temp_icns"
            debug_log "Successfully extracted icon from Assets.car"
            return 0
        fi
    fi
    
    rm -f "$temp_icns"
    return 1
}

# Function to get icon using native macOS methods
get_app_icon_native() {
    local app_name="$1"
    local output_path="$2"
    
    debug_log "Getting native icon for: $app_name"
    
    # Get app bundle path
    local bundle_path
    bundle_path=$(get_app_bundle_path "$app_name")
    
    if [ -z "$bundle_path" ] || [ ! -d "$bundle_path" ]; then
        debug_log "No valid bundle path found"
        return 1
    fi
    
    # Try to get icon name from bundle
    local icon_name
    icon_name=$(get_bundle_icon_name "$bundle_path")
    
    # Method 1: Look for .icns file in Resources
    local resources_dir="$bundle_path/Contents/Resources"
    if [ -d "$resources_dir" ]; then
        # Try with explicit icon name
        if [ -n "$icon_name" ]; then
            local icns_file="$resources_dir/${icon_name}.icns"
            if extract_from_icns "$icns_file" "$output_path"; then
                return 0
            fi
            
            # Try without .icns extension in case it's already included
            icns_file="$resources_dir/${icon_name}"
            if extract_from_icns "$icns_file" "$output_path"; then
                return 0
            fi
        fi
        
        # Try common icon names
        local common_names=("app" "application" "icon" "AppIcon")
        for name in "${common_names[@]}"; do
            local icns_file="$resources_dir/${name}.icns"
            if extract_from_icns "$icns_file" "$output_path"; then
                return 0
            fi
        done
        
        # Try any .icns file
        local first_icns
        first_icns=$(find "$resources_dir" -name "*.icns" -type f | head -1)
        if [ -n "$first_icns" ] && extract_from_icns "$first_icns" "$output_path"; then
            return 0
        fi
    fi
    
    # Method 2: Try Assets.car
    local assets_car="$resources_dir/Assets.car"
    if [ -f "$assets_car" ] && [ -n "$icon_name" ]; then
        if extract_from_assets_car "$assets_car" "$icon_name" "$output_path"; then
            return 0
        fi
    fi
    
    # Method 3: Use osascript to get icon (fallback)
    debug_log "Trying osascript method"
    local temp_icns=$(mktemp -t "app_icon_XXXXXX.icns")
    
    if osascript -e "
        try
            tell application \"Finder\"
                set appFile to POSIX file \"$bundle_path\" as alias
                set iconData to icon of appFile
                set iconFile to open for access file \"$temp_icns\" with write permission
                write iconData to iconFile
                close access iconFile
                return \"success\"
            end tell
        on error errMsg
            return \"error: \" & errMsg
        end try
    " >/dev/null 2>&1; then
        if extract_from_icns "$temp_icns" "$output_path"; then
            rm -f "$temp_icns"
            debug_log "Successfully extracted icon using osascript"
            return 0
        fi
    fi
    
    rm -f "$temp_icns"
    return 1
}

# Function to generate safe cache filename
get_cache_filename() {
    local app_name="$1"
    # Replace spaces and special characters with underscores
    local safe_name=$(echo "$app_name" | sed 's/[^a-zA-Z0-9]/_/g' | tr '[:upper:]' '[:lower:]')
    echo "${safe_name}.${ICON_FORMAT}"
}

# Function to check if cached icon exists and is recent
is_cache_valid() {
    local cache_file="$1"
    local max_age_seconds=$((MAX_CACHE_AGE_DAYS * 24 * 3600))
    
    if [ ! -f "$cache_file" ]; then
        return 1
    fi
    
    # Check if file is newer than max age
    if [ "$(find "$cache_file" -newermt "-${MAX_CACHE_AGE_DAYS} days" 2>/dev/null)" ]; then
        return 0
    fi
    
    return 1
}

# Main function to get app icon
get_app_icon() {
    local app_name="$1"
    
    if [ -z "$app_name" ]; then
        echo ""
        return 1
    fi
    
    debug_log "Getting icon for app: $app_name"
    
    # Generate cache filename
    local cache_filename
    cache_filename=$(get_cache_filename "$app_name")
    local cache_file="$ICON_CACHE_DIR/$cache_filename"
    
    # Check if we have a valid cached icon
    if is_cache_valid "$cache_file"; then
        debug_log "Using cached icon: $cache_file"
        echo "$cache_file"
        return 0
    fi
    
    # Clean old cache files periodically (10% chance)
    if [ $((RANDOM % 10)) -eq 0 ]; then
        clean_cache
    fi
    
    debug_log "Cache miss, extracting new icon"
    
    # Try to extract native app icon
    if get_app_icon_native "$app_name" "$cache_file"; then
        debug_log "Successfully extracted native icon"
        echo "$cache_file"
        return 0
    fi
    
    debug_log "Failed to extract native icon for $app_name"
    return 1
}

# Main script execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <app_name>"
    exit 1
fi

app_name="$1"
icon_path=$(get_app_icon "$app_name")

if [ -n "$icon_path" ] && [ -f "$icon_path" ]; then
    echo "$icon_path"
    exit 0
else
    exit 1
fi