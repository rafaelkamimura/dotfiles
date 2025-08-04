#!/bin/bash

# Simple App Icons - Returns actual SF Symbol characters
case "$1" in
    # System apps
    "Finder") echo "";;  # folder.fill SF Symbol
    "System Preferences"|"System Settings") echo "";;  # gear SF Symbol
    
    # Browsers  
    "Google Chrome"|"Chromium") echo "🌐";;
    "Safari") echo "";;
    "Firefox") echo "🦊";;
    
    # Terminals
    "Terminal") echo "";;  # terminal.fill SF Symbol
    "iTerm2") echo "";;
    "ghostty"|"Ghostty") echo "";;  # terminal SF Symbol
    "Alacritty") echo "";;
    
    # Development  
    "Docker"|"Docker Desktop") echo "";;  # shippingbox.fill SF Symbol
    "Visual Studio Code"|"Code") echo "💻";;
    "Xcode") echo "🔨";;
    
    # Media
    "Spotify") echo "";;  # music.note SF Symbol  
    "Music"|"Apple Music") echo "";;
    "VLC") echo "📹";;
    
    # Communication
    "Slack") echo "💬";;
    "Discord") echo "🎮";;
    "Zoom") echo "📹";;
    
    # Productivity
    "Notes") echo "📝";;
    "TextEdit") echo "📄";;
    "Preview") echo "👁";;
    
    # Fallback - try to guess based on name
    *) 
        if [[ "$1" == *"Browser"* ]] || [[ "$1" == *"browser"* ]]; then
            echo "🌐"
        elif [[ "$1" == *"Terminal"* ]] || [[ "$1" == *"terminal"* ]]; then
            echo ""
        elif [[ "$1" == *"Music"* ]] || [[ "$1" == *"music"* ]]; then
            echo ""
        elif [[ "$1" == *"Video"* ]] || [[ "$1" == *"video"* ]]; then
            echo "📹"
        else
            echo "📱"  # Generic app icon
        fi
        ;;
esac