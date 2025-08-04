#!/bin/bash

# SketchyBar Icon System Configuration Helper
# Helps users configure and test the new app icon system

SCRIPT_DIR="$HOME/.config/sketchybar"
cd "$SCRIPT_DIR" || exit 1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SketchyBar Enhanced App Icon System Configuration ===${NC}"
echo ""

# Function to show current configuration
show_config() {
    echo -e "${YELLOW}Current Configuration:${NC}"
    
    if grep -q "PREFER_NATIVE_ICONS=true" plugins/app_dock.sh 2>/dev/null; then
        echo -e "  Icon Preference: ${GREEN}Native icons preferred${NC}"
    elif grep -q "PREFER_NATIVE_ICONS=false" plugins/app_dock.sh 2>/dev/null; then
        echo -e "  Icon Preference: ${GREEN}SF Symbols preferred${NC}"
    else
        echo -e "  Icon Preference: ${RED}Not configured${NC}"
    fi
    
    # Check cache status
    if [ -d "$HOME/.config/sketchybar/cache/icons" ]; then
        local cache_count=$(ls -1 "$HOME/.config/sketchybar/cache/icons"/*.png 2>/dev/null | wc -l)
        echo -e "  Icon Cache: ${GREEN}$cache_count cached icons${NC}"
    else
        echo -e "  Icon Cache: ${YELLOW}No cache directory${NC}"
    fi
    
    # Check if scripts are executable
    local scripts=("plugins/app_icon_system.sh" "plugins/app_icon_extractor.sh" "plugins/app_dock.sh")
    local executable_count=0
    for script in "${scripts[@]}"; do
        if [ -x "$script" ]; then
            ((executable_count++))
        fi
    done
    echo -e "  Script Status: ${GREEN}$executable_count/3 scripts executable${NC}"
    echo ""
}

# Function to set icon preference
set_preference() {
    local preference="$1"
    
    if [ "$preference" = "native" ]; then
        sed -i '' 's/PREFER_NATIVE_ICONS=.*/PREFER_NATIVE_ICONS=true/' plugins/app_dock.sh
        echo -e "${GREEN}✓ Set preference to native icons${NC}"
    elif [ "$preference" = "sf" ]; then
        sed -i '' 's/PREFER_NATIVE_ICONS=.*/PREFER_NATIVE_ICONS=false/' plugins/app_dock.sh
        echo -e "${GREEN}✓ Set preference to SF Symbols${NC}"
    else
        echo -e "${RED}✗ Invalid preference. Use 'native' or 'sf'${NC}"
        return 1
    fi
}

# Function to clear cache
clear_cache() {
    local cache_dir="$HOME/.config/sketchybar/cache/icons"
    if [ -d "$cache_dir" ]; then
        local count=$(ls -1 "$cache_dir"/*.png 2>/dev/null | wc -l)
        rm -f "$cache_dir"/*.png
        echo -e "${GREEN}✓ Cleared $count cached icons${NC}"
    else
        echo -e "${YELLOW}No cache to clear${NC}"
    fi
}

# Function to test icons
test_icons() {
    echo -e "${YELLOW}Testing icon system with current running apps...${NC}"
    echo ""
    
    # Get running apps
    local apps
    apps=$(osascript -e 'tell application "System Events" to return name of every application process whose background only is false' 2>/dev/null | tr ',' '\n' | sed 's/^ *//' | head -5)
    
    while IFS= read -r app; do
        if [ -n "$app" ]; then
            local sf_icon native_icon
            sf_icon=$(./plugins/app_icon_system.sh "$app" false 2>/dev/null)
            native_icon=$(./plugins/app_icon_system.sh "$app" true 2>/dev/null)
            
            echo -e "  ${BLUE}$app${NC}"
            echo -e "    SF Symbol: $sf_icon"
            echo -e "    With native pref: $native_icon"
            
            # Check if native extraction is available
            if ./plugins/app_icon_extractor.sh "$app" >/dev/null 2>&1; then
                echo -e "    ${GREEN}✓ Native icon available${NC}"
            else
                echo -e "    ${YELLOW}○ Native icon not available${NC}"
            fi
            echo ""
        fi
    done <<< "$apps"
}

# Function to ensure scripts are executable
fix_permissions() {
    local scripts=("plugins/app_icon_system.sh" "plugins/app_icon_extractor.sh" "plugins/app_dock.sh" "test_icon_system.sh")
    local fixed=0
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ] && [ ! -x "$script" ]; then
            chmod +x "$script"
            ((fixed++))
        fi
    done
    
    if [ $fixed -gt 0 ]; then
        echo -e "${GREEN}✓ Fixed permissions for $fixed scripts${NC}"
    else
        echo -e "${GREEN}✓ All scripts have correct permissions${NC}"
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status      Show current configuration status"
    echo "  prefer-sf   Prefer SF Symbols over native icons"
    echo "  prefer-native Prefer native icons over SF Symbols"
    echo "  clear-cache Clear all cached icons"
    echo "  test        Test icon resolution with running apps"
    echo "  fix-perms   Fix script permissions"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 status                 # Show current configuration"
    echo "  $0 prefer-sf             # Use SF Symbols when available"
    echo "  $0 prefer-native         # Extract native icons when possible"
    echo "  $0 test                  # Test with current running apps"
}

# Main execution
case "${1:-status}" in
    "status")
        show_config
        ;;
    "prefer-sf")
        set_preference "sf"
        ;;
    "prefer-native")
        set_preference "native"
        ;;
    "clear-cache")
        clear_cache
        ;;
    "test")
        test_icons
        ;;
    "fix-perms")
        fix_permissions
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

echo -e "${BLUE}=== Configuration Complete ===${NC}"