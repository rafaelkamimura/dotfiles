#!/bin/bash

# Test Dialog Centering Script
# Tests if native macOS dialogs (file pickers) are properly centered

echo "🔍 Testing Dialog Centering Configuration"
echo "=========================================="
echo ""

# Check if yabai is running
if ! pgrep -x "yabai" > /dev/null; then
    echo "❌ yabai is not running!"
    echo "   Start with: yabai --start-service"
    exit 1
fi

echo "✅ yabai is running"
echo ""

# Check if dialog rules are loaded
echo "📋 Checking dialog rules..."
DIALOG_RULES=$(yabai -m rule --list | grep -c "AXDialog")

if [[ $DIALOG_RULES -gt 0 ]]; then
    echo "✅ Found $DIALOG_RULES dialog-related rules"
else
    echo "❌ No dialog rules found!"
    echo "   Restart yabai: yabai --restart-service"
    exit 1
fi

echo ""
echo "🎯 Active Dialog Rules:"
yabai -m rule --list | jq -r '.[] | select(.subrole | test("Dialog")) | "  - Subrole: \(.subrole) → Grid: \(.grid)"'

echo ""
echo "📊 Signals loaded:"
SIGNALS=$(yabai -m signal --list | grep -c "window_created")
echo "  - window_created signals: $SIGNALS"

echo ""
echo "🧪 To test:"
echo "  1. Open Claude Desktop"
echo "  2. Try to upload a file (trigger file picker)"
echo "  3. The dialog should now be CENTERED at 75% screen size"
echo ""
echo "If not centered, try manually with: Ctrl+Alt+C"
echo ""
echo "Debug current window:"
echo "  yabai -m query --windows --window | jq '{app, title, subrole, \"is-floating\": .\"is-floating\", frame}'"
