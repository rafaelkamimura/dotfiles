#!/bin/bash

# Emoji fallback for apps that don't have real icons available
case "$1" in
# Browsers - More distinctive
"Arc") echo "🌈";;
"Safari") echo "🧭";;
"Firefox") echo "🔥";;
"Google Chrome") echo "󰊯";;
"Chromium") echo "🔵";;
"Edge") echo "🌊";;
"Brave Browser") echo "🦁";;
"Opera") echo "🎭";;

# Terminals - More distinctive
"Terminal") echo "";;
"iTerm2") echo "";;
"Ghostty") echo "👻";;
"Alacritty") echo "🚀";;
"Kitty") echo "🐱";;
"Warp") echo "🌀";;
"Hyper") echo "⚡";;

# Code Editors - Better visual distinction
"Code") echo "󰨞";;
"Visual Studio Code") echo "󰨞";;
"Xcode") echo "";;
"Vim") echo "";;
"Neovim") echo "";;
"Sublime Text") echo "🟠";;
"Atom") echo "⚛️";;
"IntelliJ IDEA") echo "🧠";;
"WebStorm") echo "🌐";;
"PyCharm") echo "🐍";;
"Android Studio") echo "🤖";;
"Cursor") echo "🎯";;

# System - More recognizable
"Finder") echo "";;
"System Preferences") echo "";;
"System Settings") echo "";;
"Activity Monitor") echo "";;
"Console") echo "";;
"Disk Utility") echo "💾";;
"Keychain Access") echo "🔐";;

# Media - Better visual appeal
"Spotify") echo "";;
"Music") echo "";;
"Apple Music") echo "";;
"YouTube Music") echo "🎥";;
"SoundCloud") echo "☁️";;
"VLC") echo "󰕼";;
"IINA") echo "🎬";;
"QuickTime Player") echo "";;
"Final Cut Pro") echo "";;
"Logic Pro") echo "";;
"GarageBand") echo "🎸";;

# Communication - More expressive
"Discord") echo "󰙯";;
"Slack") echo "󰒱";;
"Telegram") echo "";;
"WhatsApp") echo "";;
"Signal") echo "🔒";;
"Messages") echo "💬";;
"FaceTime") echo "📹";;
"Zoom") echo "";;
"Microsoft Teams") echo "󰊻";;
"Skype") echo "📞";;

# Productivity - Cleaner icons
"Mail") echo "";;
"Calendar") echo "";;
"Notes") echo "";;
"Reminders") echo "✅";;
"Contacts") echo "👤";;
"Raycast") echo "󰍉";;
"Alfred") echo "🎩";;
"Spotlight") echo "🔍";;

# Development - More specific
"Docker") echo "";;
"Docker Desktop") echo "";;
"Postman") echo "󰛮";;
"Insomnia") echo "😴";;
"GitHub Desktop") echo "";;
"Tower") echo "󰊢";;
"SourceTree") echo "🌳";;
"GitKraken") echo "🐙";;
"TablePlus") echo "📊";;
"Sequel Pro") echo "🗄️";;
"MongoDB Compass") echo "🍃";;

# Design - More creative
"Figma") echo "";;
"Sketch") echo "";;
"Adobe XD") echo "🎨";;
"Photoshop") echo "";;
"Illustrator") echo "";;
"InDesign") echo "📄";;
"After Effects") echo "🎬";;
"Premiere Pro") echo "🎞️";;
"Blender") echo "🌀";;

# Office - Professional look
"Excel") echo "󰈛";;
"Word") echo "󰈬";;
"PowerPoint") echo "󰈧";;
"OneNote") echo "󰠮";;
"Notion") echo "󰈙";;
"Obsidian") echo "󰠮";;
"Bear") echo "🐻";;
"Typora") echo "📝";;

# Utilities - More intuitive
"1Password") echo "";;
"Bitwarden") echo "🔐";;
"CleanMyMac") echo "󰃢";;
"AppCleaner") echo "🗑️";;
"The Unarchiver") echo "📦";;
"Keka") echo "📦";;
"Preview") echo "";;
"TextEdit") echo "📝";;
"Calculator") echo "🧮";;

# Entertainment - More fun
"Netflix") echo "🎬";;
"YouTube") echo "📺";;
"Twitch") echo "🎮";;
"Steam") echo "🎮";;
"Epic Games") echo "🎮";;

# File Management - Cloud themed
"Dropbox") echo "📦";;
"Google Drive") echo "☁️";;
"OneDrive") echo "☁️";;
"iCloud") echo "☁️";;

# Virtual Machines - Tech themed
"VMware Fusion") echo "💻";;
"Parallels Desktop") echo "💻";;
"VirtualBox") echo "📦";;

# Additional popular apps
"ChatGPT") echo "🤖";;
"Claude") echo "🤖";;
"Perplexity") echo "🔍";;
"Linear") echo "📐";;
"Loom") echo "🎥";;
"Canva") echo "🎨";;

# Default fallback - more appealing
*) echo "";;
esac