local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local animations = require("helpers.animations")

-- Quick shortcuts manager for frequently used applications and system functions
local shortcuts_widget = sbar.add("item", "widgets.shortcuts_manager", {
  position = "right",
  icon = {
    string = "🚀",
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    }
  },
  label = {
    string = "Quick",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Medium"],
      size = 10.0,
    },
    color = colors.white
  },
  popup = {
    align = "center",
    horizontal = false,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/shortcuts_manager.sh click"
})

-- Application shortcuts in popup
local app_shortcuts = {}
local app_list = {
  {name = "Activity Monitor", icon = "⚡", command = "open -a 'Activity Monitor'"},
  {name = "Terminal", icon = "💻", command = "open -a 'Terminal'"},
  {name = "System Preferences", icon = "⚙️", command = "open -a 'System Preferences'"},
  {name = "Calculator", icon = "🧮", command = "open -a 'Calculator'"},
  {name = "TextEdit", icon = "📝", command = "open -a 'TextEdit'"},
  {name = "Finder", icon = "📁", command = "open -a 'Finder'"}
}

for i, app in ipairs(app_list) do
  local app_item = sbar.add("item", {
    position = "popup." .. shortcuts_widget.name,
    icon = {
      string = app.icon .. " " .. app.name,
      width = 160,
      align = "left",
      font = { size = 11.0 }
    },
    label = { string = "" },
    click_script = string.format("$CONFIG_DIR/plugins/shortcuts_manager.sh app '%s'", app.command)
  })
  table.insert(app_shortcuts, app_item)
end

-- Separator for system functions
local system_separator = sbar.add("item", {
  position = "popup." .. shortcuts_widget.name,
  icon = {
    string = "═══ System ═══",
    width = 160,
    align = "center",
    font = { size = 10.0, style = settings.font.style_map["Bold"] },
    color = colors.grey
  },
  label = { string = "" }
})

-- System function shortcuts
local system_shortcuts = {}
local system_list = {
  {name = "Lock Screen", icon = "🔒", command = "pmset displaysleepnow"},
  {name = "Sleep", icon = "💤", command = "pmset sleepnow"},
  {name = "Restart", icon = "🔄", command = "sudo shutdown -r now"},
  {name = "Empty Trash", icon = "🗑️", command = "osascript -e 'tell application \"Finder\" to empty trash'"},
  {name = "Toggle WiFi", icon = "📶", command = "networksetup -setairportpower en0 off && sleep 2 && networksetup -setairportpower en0 on"},
  {name = "Screenshot", icon = "📸", command = "screencapture -c"}
}

for i, func in ipairs(system_list) do
  local system_item = sbar.add("item", {
    position = "popup." .. shortcuts_widget.name,
    icon = {
      string = func.icon .. " " .. func.name,
      width = 160,
      align = "left",
      font = { size = 11.0 }
    },
    label = { string = "" },
    click_script = string.format("$CONFIG_DIR/plugins/shortcuts_manager.sh system '%s'", func.command)
  })
  table.insert(system_shortcuts, system_item)
end

-- Separator for quick actions
local actions_separator = sbar.add("item", {
  position = "popup." .. shortcuts_widget.name,
  icon = {
    string = "═══ Actions ═══",
    width = 160,
    align = "center",
    font = { size = 10.0, style = settings.font.style_map["Bold"] },
    color = colors.grey
  },
  label = { string = "" }
})

-- Quick action shortcuts
local action_shortcuts = {}
local action_list = {
  {name = "Copy IP Address", icon = "🌐", command = "ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1 | pbcopy"},
  {name = "Show Hidden Files", icon = "👁️", command = "defaults write com.apple.finder AppleShowAllFiles YES && killall Finder"},
  {name = "Hide Hidden Files", icon = "🙈", command = "defaults write com.apple.finder AppleShowAllFiles NO && killall Finder"},
  {name = "Clear DNS Cache", icon = "🔄", command = "sudo dscacheutil -flushcache"},
  {name = "CPU Temperature", icon = "🌡️", command = "sudo powermetrics -n 1 -i 1000 --samplers smc | grep 'CPU die temperature'"},
  {name = "Disk Usage", icon = "💾", command = "df -h | head -5"}
}

for i, action in ipairs(action_list) do
  local action_item = sbar.add("item", {
    position = "popup." .. shortcuts_widget.name,
    icon = {
      string = action.icon .. " " .. action.name,
      width = 160,
      align = "left",
      font = { size = 11.0 }
    },
    label = { string = "" },
    click_script = string.format("$CONFIG_DIR/plugins/shortcuts_manager.sh action '%s'", action.command)
  })
  table.insert(action_shortcuts, action_item)
end

-- Add hover effects to all shortcuts
local function add_hover_effects(items)
  for _, item in ipairs(items) do
    local hover_effect = animations.hover_effect(item, colors.with_alpha(colors.blue, 0.4))
    
    item:subscribe("mouse.entered", function()
      hover_effect.enter()
    end)
    
    item:subscribe("mouse.exited", function()
      hover_effect.exit()
    end)
  end
end

-- Apply hover effects
add_hover_effects(app_shortcuts)
add_hover_effects(system_shortcuts)
add_hover_effects(action_shortcuts)

-- Mouse interactions for main widget
shortcuts_widget:subscribe("mouse.clicked", function(env)
  local current_drawing = shortcuts_widget:query().popup.drawing
  shortcuts_widget:set({ popup = { drawing = "toggle" } })
  
  if current_drawing == "off" then
    animations.fade_in(shortcuts_widget, 0.3)
  else
    animations.fade_out(shortcuts_widget, 0.2)
  end
end)

-- Enhanced hover effects for main widget
local main_hover_effect = animations.hover_effect(shortcuts_widget, colors.with_alpha(colors.orange, 0.6))

shortcuts_widget:subscribe("mouse.entered", function(env)
  main_hover_effect.enter()
end)

shortcuts_widget:subscribe("mouse.exited", function(env)
  main_hover_effect.exit()
end)

-- Update shortcuts based on most used applications
shortcuts_widget:subscribe("shortcuts_update", function(env)
  -- This could be enhanced to show dynamic shortcuts based on usage
  local most_used = env.most_used_apps or ""
  
  -- Simple visual feedback for now
  shortcuts_widget:set({
    icon = { color = colors.orange }
  })
end)

-- Background bracket
sbar.add("bracket", "widgets.shortcuts_manager.bracket", { shortcuts_widget.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.shortcuts_manager.padding", {
  position = "right",
  width = settings.group_paddings
})