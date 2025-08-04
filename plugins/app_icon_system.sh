#!/bin/bash

# Enhanced App Icon System for SketchyBar
# Provides a comprehensive icon resolution system with multiple fallback methods:
# 1. SF Symbols (native macOS symbols)
# 2. Extracted app icons (.icns/.png)
# 3. Nerd Font icons
# 4. Emoji fallbacks

source "$HOME/.config/sketchybar/variables.sh"

# Configuration
SCRIPT_DIR="$HOME/.config/sketchybar/plugins"
ICON_EXTRACTOR="$SCRIPT_DIR/app_icon_extractor.sh"
ICON_MAP="$SCRIPT_DIR/icon_map.sh"

# Function to log debug messages
debug_log() {
    if [ "${SKETCHYBAR_DEBUG:-0}" = "1" ]; then
        echo "[DEBUG] app_icon_system: $1" >&2
    fi
}

# SF Symbols mapping for common apps
# These are native macOS symbols that look great and are always available
get_sf_symbol() {
    local app_name="$1"
    
    case "$app_name" in
        # Browsers
        "Safari"|"Safari浏览器"|"Safari Technology Preview")
            echo "safari";;
        "Google Chrome"|"Chromium")
            echo "globe";;
        "Firefox"|"Firefox Developer Edition"|"Firefox Nightly")
            echo "network";;
        "Arc")
            echo "arc.forward";;
        "Microsoft Edge")
            echo "globe";;
        "Opera")
            echo "globe";;
        "Brave Browser")
            echo "shield";;
            
        # System Apps
        "Finder"|"访达")
            echo "folder";;
        "System Preferences"|"System Settings"|"系统设置"|"Réglages Système")
            echo "gearshape";;
        "Activity Monitor")
            echo "chart.bar";;
        "Console")
            echo "terminal";;
        "Disk Utility")
            echo "externaldrive";;
        "Keychain Access")
            echo "key";;
        "Preview"|"预览"|"Aperçu")
            echo "doc.richtext";;
        "Calculator"|"Calculette")
            echo "plus.forwardslash.minus";;
        "TextEdit")
            echo "doc.text";;
            
        # Terminals
        "Terminal"|"终端")
            echo "terminal";;
        "iTerm"|"iTerm2")
            echo "terminal";;
        "Alacritty")
            echo "terminal.fill";;
        "Kitty"|"kitty")
            echo "terminal.fill";;
        "Warp")
            echo "bolt";;
        "Hyper")
            echo "terminal.fill";;
        "ghostty"|"Ghostty")
            echo "terminal";;
            
        # Development
        "Code"|"Visual Studio Code"|"Code - Insiders")
            echo "chevron.left.forwardslash.chevron.right";;
        "Xcode")
            echo "hammer";;
        "Android Studio")
            echo "hammer";;
        "IntelliJ IDEA"|"PyCharm"|"WebStorm"|"PhpStorm"|"GoLand"|"Rider"|"DataGrip"|"DataSpell")
            echo "hammer";;
        "Sublime Text")
            echo "doc.text";;
        "Atom")
            echo "atom";;
        "Vim"|"MacVim"|"Neovim"|"neovim"|"nvim"|"VimR")
            echo "doc.text";;
        "Cursor")
            echo "cursorarrow.rays";;
        "Zed")
            echo "bolt";;
            
        # Version Control
        "GitHub Desktop")
            echo "square.and.arrow.up.on.square";;
        "Tower")
            echo "arrow.triangle.branch";;
        "SourceTree")
            echo "arrow.triangle.branch";;
        "Fork")
            echo "tuningfork";;
            
        # Design
        "Figma")
            echo "paintbrush";;
        "Sketch")
            echo "paintbrush";;
        "Adobe Photoshop"|"Photoshop")
            echo "photo";;
        "Adobe Illustrator"|"Illustrator")
            echo "paintbrush.pointed";;
        "Adobe InDesign"|"InDesign")
            echo "doc";;
        "Adobe XD")
            echo "square.and.pencil";;
        "Blender")
            echo "cube.box";;
        "Canva")
            echo "paintbrush";;
            
        # Media
        "Music"|"音乐"|"Musique"|"Apple Music")
            echo "music.note";;
        "Spotify")
            echo "music.note.list";;
        "VLC")
            echo "play.rectangle";;
        "IINA")
            echo "play.rectangle.fill";;
        "QuickTime Player")
            echo "play.rectangle";;
        "Final Cut Pro")
            echo "film";;
        "Logic Pro")
            echo "music.mic";;
        "GarageBand")
            echo "music.mic";;
        "YouTube"|"YouTube Music")
            echo "play.tv";;
        "Netflix")
            echo "tv";;
        "Twitch")
            echo "play.tv";;
            
        # Communication
        "Messages"|"信息"|"Nachrichten")
            echo "message";;
        "FaceTime"|"FaceTime 通话")
            echo "video";;
        "Mail"|"邮件"|"HEY"|"Superhuman"|"Spark"|"Canary Mail"|"Mailspring"|"MailMate")
            echo "envelope";;
        "Discord")
            echo "message.circle";;
        "Slack")
            echo "message.badge";;
        "Telegram")
            echo "paperplane";;
        "WhatsApp"|"‎WhatsApp")
            echo "message.circle.fill";;
        "Signal")
            echo "message.and.waveform";;
        "Microsoft Teams"|"Microsoft Teams (work or school)")
            echo "video.bubble.left";;
        "Zoom"|"zoom.us")
            echo "video";;
        "Skype")
            echo "video.circle";;
            
        # Productivity
        "Calendar"|"日历"|"Calendrier"|"Fantastical"|"Cron"|"Amie"|"BusyCal"|"Notion Calendar")
            echo "calendar";;
        "Notes"|"备忘录")
            echo "note.text";;
        "Reminders"|"提醒事项"|"Rappels")
            echo "checklist";;
        "Contacts")
            echo "person.crop.circle";;
        "Notion")
            echo "doc.text";;
        "Obsidian")
            echo "link";;
        "Bear")
            echo "note.text";;
        "Typora")
            echo "doc.richtext";;
        "Microsoft Word")
            echo "doc.text";;
        "Microsoft Excel")
            echo "tablecells";;
        "Microsoft PowerPoint")
            echo "rectangle.on.rectangle";;
        "Pages"|"Pages 文稿")
            echo "doc.richtext";;
        "Numbers"|"Numbers 表格")
            echo "tablecells";;
        "Keynote"|"Keynote 讲演")
            echo "rectangle.on.rectangle";;
            
        # Utilities
        "1Password")
            echo "key.fill";;
        "Bitwarden")
            echo "lock.shield";;
        "CleanMyMac"|"CleanMyMac X")
            echo "trash";;
        "AppCleaner"|"App Eraser")
            echo "trash.circle";;
        "The Unarchiver"|"Keka")
            echo "archivebox";;
        "Raycast")
            echo "magnifyingglass.circle";;
        "Alfred")
            echo "magnifyingglass";;
        "Spotlight")
            echo "magnifyingglass";;
            
        # Development Tools
        "Docker"|"Docker Desktop")
            echo "shippingbox";;
        "Postman")
            echo "network";;
        "Insomnia")
            echo "bolt.horizontal";;
        "TablePlus"|"Sequel Pro"|"Sequel Ace")
            echo "cylinder.split.1x2";;
        "MongoDB Compass")
            echo "cylinder";;
            
        # Cloud Storage
        "Dropbox")
            echo "folder.badge.plus";;
        "Google Drive")
            echo "icloud";;
        "OneDrive")
            echo "icloud";;
        "iCloud")
            echo "icloud.fill";;
            
        # Virtual Machines
        "VMware Fusion"|"Parallels Desktop"|"VirtualBox"|"UTM")
            echo "desktopcomputer";;
            
        # Gaming
        "Steam"|"Epic Games")
            echo "gamecontroller";;
        "League of Legends")
            echo "gamecontroller.fill";;
            
        # Default fallback
        *)
            return 1;;
    esac
    return 0
}

# Function to get Nerd Font icon (from existing system)
get_nerd_font_icon() {
    local app_name="$1"
    
    # Check if we have a Nerd Font icon in the Lua helper
    if [ -f "$HOME/.config/sketchybar/helpers/app_icons.lua" ]; then
        local icon_code
        icon_code=$(lua -e "
            local icons = dofile('$HOME/.config/sketchybar/helpers/app_icons.lua')
            local icon = icons['$app_name']
            if icon then
                print(icon)
            end
        " 2>/dev/null)
        
        if [ -n "$icon_code" ] && [ "$icon_code" != "nil" ]; then
            debug_log "Found Nerd Font icon for $app_name: $icon_code"
            echo "$icon_code"
            return 0
        fi
    fi
    
    return 1
}

# Function to get emoji fallback
get_emoji_fallback() {
    local app_name="$1"
    
    if [ -f "$ICON_MAP" ]; then
        local emoji_icon
        emoji_icon=$("$ICON_MAP" "$app_name" 2>/dev/null)
        
        if [ -n "$emoji_icon" ] && [ "$emoji_icon" != "" ]; then
            debug_log "Found emoji fallback for $app_name: $emoji_icon"
            echo "$emoji_icon"
            return 0
        fi
    fi
    
    return 1
}

# Main function to get app icon with comprehensive fallback system
get_app_icon() {
    local app_name="$1"
    local prefer_native="${2:-true}"  # Default to preferring native icons
    
    if [ -z "$app_name" ]; then
        echo ""
        return 1
    fi
    
    debug_log "Getting icon for: $app_name (prefer_native: $prefer_native)"
    
    # Method 1: Try SF Symbols first (native macOS, always crisp)
    local sf_symbol
    if sf_symbol=$(get_sf_symbol "$app_name"); then
        debug_log "Using SF Symbol: $sf_symbol"
        echo "$sf_symbol"
        return 0
    fi
    
    # Method 2: Try native app icon extraction (if preferred and extractor exists)
    if [ "$prefer_native" = "true" ] && [ -x "$ICON_EXTRACTOR" ]; then
        local native_icon
        if native_icon=$("$ICON_EXTRACTOR" "$app_name" 2>/dev/null); then
            debug_log "Using native extracted icon: $native_icon"
            echo "$native_icon"
            return 0
        fi
    fi
    
    # Method 3: Try Nerd Font icons
    local nerd_icon
    if nerd_icon=$(get_nerd_font_icon "$app_name"); then
        debug_log "Using Nerd Font icon: $nerd_icon"
        echo "$nerd_icon"
        return 0
    fi
    
    # Method 4: Try native app icon extraction (if not already tried)
    if [ "$prefer_native" != "true" ] && [ -x "$ICON_EXTRACTOR" ]; then
        local native_icon
        if native_icon=$("$ICON_EXTRACTOR" "$app_name" 2>/dev/null); then
            debug_log "Using native extracted icon: $native_icon"
            echo "$native_icon"
            return 0
        fi
    fi
    
    # Method 5: Emoji fallback
    local emoji_icon
    if emoji_icon=$(get_emoji_fallback "$app_name"); then
        debug_log "Using emoji fallback: $emoji_icon"
        echo "$emoji_icon"
        return 0
    fi
    
    # Method 6: Generic fallback
    debug_log "Using generic fallback for: $app_name"
    echo ""  # Generic app icon
    return 0
}

# Function to determine if an icon is a file path or symbol/text
is_icon_file() {
    local icon="$1"
    
    # Check if it's a file path (contains / and exists)
    if [[ "$icon" == *"/"* ]] && [ -f "$icon" ]; then
        return 0
    fi
    
    return 1
}

# Function to get icon properties for SketchyBar configuration
get_icon_properties() {
    local app_name="$1"
    local prefer_native="${2:-true}"
    
    local icon
    icon=$(get_app_icon "$app_name" "$prefer_native")
    
    if is_icon_file "$icon"; then
        # For image files, use drawing mode and set font to system
        echo "icon=\"$icon\" icon.drawing=on icon.font=\"SF Pro:Regular:16.0\""
    else
        # For text/symbols, use regular text rendering
        if [[ "$icon" == :*: ]]; then
            # Nerd Font icon
            echo "icon=\"$icon\" icon.font=\"Hack Nerd Font:Regular:18.0\""
        else
            # SF Symbol or emoji
            echo "icon=\"$icon\" icon.font=\"SF Pro:Regular:18.0\""
        fi
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <app_name> [prefer_native]"
    echo "       $0 --properties <app_name> [prefer_native]  # Output SketchyBar properties"
    exit 1
fi

if [ "$1" = "--properties" ]; then
    shift
    get_icon_properties "$@"
else
    get_app_icon "$@"
fi