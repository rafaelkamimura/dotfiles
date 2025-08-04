#!/bin/bash

# System shortcuts and quick actions
case "$1" in
    "wifi_toggle")
        WIFI_STATUS=$(networksetup -getairportpower en0 | awk '{print $4}')
        if [ "$WIFI_STATUS" = "On" ]; then
            networksetup -setairportpower en0 off
            sketchybar --set network label="WiFi Off"
        else
            networksetup -setairportpower en0 on
            sketchybar --set network label="WiFi On"
        fi
        ;;
    "bluetooth_toggle")
        BT_STATUS=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null)
        if [ "$BT_STATUS" = "1" ]; then
            sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
            sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
            sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist
        else
            sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 1
            sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
            sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist
        fi
        ;;
    "dnd_toggle")
        # Toggle Do Not Disturb
        osascript -e 'tell application "System Events" to keystroke "D" using {command down, shift down, option down, control down}'
        ;;
    "sleep")
        pmset sleepnow
        ;;
    "lock")
        /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
        ;;
esac