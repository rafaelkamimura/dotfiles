-- Accessible battery widget for SketchyBar
-- Demonstrates WCAG 2.1 compliance implementation
-- Includes keyboard navigation, screen reader support, and alternative status indicators

local colors = require("colors_accessible")  -- Use accessible color scheme
local icons = require("icons")
local settings = require("settings")
local keyboard_nav = require("helpers.keyboard_navigation")
local animations = require("helpers.animations_accessible")

-- Create accessible battery widget
local battery_widget, battery_element = keyboard_nav.create_accessible_widget({
  name = "widgets.battery_accessible",
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 20.0,  -- Increased from 19.0 for better visibility
    },
    color = colors.white,
    padding_right = 4
  },
  label = { 
    font = { 
      family = settings.font.numbers,
      size = 16.0  -- Explicit size for WCAG compliance
    },
    color = colors.white,
    padding_right = 8
  },
  background = {
    height = 44,  -- WCAG minimum touch target
    color = colors.bg1,
    corner_radius = 6,
    border_width = 1,
    border_color = colors.transparent
  },
  update_freq = 120,  -- Reduced frequency for better performance
  popup = { align = "center" }
}, {
  name = "battery_status",
  description = "Battery status and level",
  aria_label = "Battery widget. Shows current battery percentage and charging status.",
  keyboard_hint = "Space to view details",
  group = "status",
  priority = 5,
  role = "status",
  activate_handler = function()
    battery_widget:set({ popup = { drawing = "toggle" } })
  end
})

-- Accessible battery details popup
local battery_details = sbar.add("item", "battery_details_accessible", {
  position = "popup." .. battery_widget.name,
  icon = {
    string = "Battery Details:",
    width = 120,
    align = "left",
    font = { size = 14.0 },
    color = colors.white
  },
  label = {
    string = "Loading...",
    width = 120,
    align = "right",
    font = { size = 14.0 },
    color = colors.white
  },
  background = {
    color = colors.bg2,
    height = 30,
    corner_radius = 4
  }
})

local remaining_time = sbar.add("item", "battery_time_accessible", {
  position = "popup." .. battery_widget.name,
  icon = {
    string = "Time remaining:",
    width = 120,
    align = "left",
    font = { size = 14.0 },
    color = colors.white
  },
  label = {
    string = "Calculating...",
    width = 120,
    align = "right",
    font = { size = 14.0 },
    color = colors.white
  },
  background = {
    color = colors.bg2,
    height = 30,
    corner_radius = 4
  }
})

local battery_health = sbar.add("item", "battery_health_accessible", {
  position = "popup." .. battery_widget.name,
  icon = {
    string = "Battery health:",
    width = 120,
    align = "left",
    font = { size = 14.0 },
    color = colors.white
  },
  label = {
    string = "Unknown",
    width = 120,
    align = "right",
    font = { size = 14.0 },
    color = colors.white
  },
  background = {
    color = colors.bg2,
    height = 30,
    corner_radius = 4
  }
})

-- Battery status state for screen reader announcements
local battery_state = {
  last_percentage = nil,
  last_charging_state = nil,
  last_announcement_time = 0,
  announcement_cooldown = 30  -- Seconds between announcements
}

-- Get accessible battery status description
local function get_battery_description(charge, charging, time_remaining)
  local status_parts = {}
  
  -- Charging status
  if charging then
    table.insert(status_parts, "Charging")
  else
    table.insert(status_parts, "On battery")
  end
  
  -- Battery level with descriptive terms
  local level_description
  if charge >= 80 then
    level_description = "High"
  elseif charge >= 60 then
    level_description = "Good"
  elseif charge >= 40 then
    level_description = "Medium"
  elseif charge >= 20 then
    level_description = "Low"
  else
    level_description = "Critical"
  end
  
  table.insert(status_parts, level_description .. " battery")
  table.insert(status_parts, tostring(charge) .. " percent")
  
  -- Time remaining
  if time_remaining and not charging then
    table.insert(status_parts, time_remaining .. " remaining")
  end
  
  return table.concat(status_parts, ". ")
end

-- Announce battery status changes to screen reader
local function announce_battery_change(charge, charging, time_remaining)
  local current_time = os.time()
  local significant_change = false
  
  -- Check for significant changes that warrant announcements
  if battery_state.last_percentage == nil then
    significant_change = true  -- First update
  elseif math.abs(charge - battery_state.last_percentage) >= 10 then
    significant_change = true  -- 10% change
  elseif battery_state.last_charging_state ~= charging then
    significant_change = true  -- Charging state changed
  elseif charge <= 20 and (current_time - battery_state.last_announcement_time) >= battery_state.announcement_cooldown then
    significant_change = true  -- Low battery periodic reminder
  end
  
  if significant_change then
    local description = get_battery_description(charge, charging, time_remaining)
    sbar.exec('say "' .. description .. '"')
    battery_state.last_announcement_time = current_time
  end
  
  battery_state.last_percentage = charge
  battery_state.last_charging_state = charging
end

-- Update battery display with accessibility features
local function update_battery_display(batt_info)
  local icon = "!"
  local label = "?"
  local icon_color = colors.white
  local bg_color = colors.bg1
  local border_color = colors.transparent
  
  local found, _, charge = batt_info:find("(%d+)%%")
  if not found then return end
  
  charge = tonumber(charge)
  label = charge .. "%"
  
  local charging = batt_info:find("AC Power") ~= nil
  
  -- Get appropriate icon and colors
  if charging then
    icon = icons.battery.charging
    icon_color = colors.status.battery.charging
  else
    if charge > 80 then
      icon = icons.battery._100
      icon_color = colors.status.battery.excellent
    elseif charge > 60 then
      icon = icons.battery._75
      icon_color = colors.status.battery.good
    elseif charge > 40 then
      icon = icons.battery._50
      icon_color = colors.status.battery.medium
    elseif charge > 20 then
      icon = icons.battery._25
      icon_color = colors.status.battery.low
      bg_color = colors.with_alpha(colors.status.battery.low, 0.2)  -- Subtle background highlight
    else
      icon = icons.battery._0
      icon_color = colors.status.battery.critical
      bg_color = colors.with_alpha(colors.status.battery.critical, 0.2)
      border_color = colors.status.battery.critical  -- Critical battery gets border
    end
  end
  
  -- Add zero padding for single digits
  local display_label = charge < 10 and "0" .. label or label
  
  -- Update widget with smooth transitions
  animations.status_change(battery_widget, icon_color, function()
    battery_widget:set({
      icon = { string = icon, color = icon_color },
      label = { string = display_label, color = colors.white },
      background = { 
        color = bg_color,
        border_color = border_color,
        border_width = border_color ~= colors.transparent and 2 or 1
      }
    })
  end)
  
  -- Extract time remaining for detailed view
  local found_time, _, time_remaining = batt_info:find(" (%d+:%d+) remaining")
  local time_str = found_time and time_remaining .. "h" or (charging and "Charging" or "No estimate")
  
  -- Announce significant changes
  announce_battery_change(charge, charging, time_str)
  
  -- Update detailed information
  battery_details:set({
    label = { string = charging and "Charging" or "Discharging" }
  })
  
  remaining_time:set({
    label = { string = time_str }
  })
  
  -- Update aria label for screen readers
  local aria_description = get_battery_description(charge, charging, time_str)
  battery_element.aria_label = "Battery: " .. aria_description
end

-- Subscribe to battery events
battery_widget:subscribe({"routine", "power_source_change", "system_woke"}, function()
  sbar.exec("pmset -g batt", function(batt_info)
    update_battery_display(batt_info)
  end)
end)

-- Handle click events (both mouse and keyboard activation)
battery_widget:subscribe("mouse.clicked", function(env)
  local drawing = battery_widget:query().popup.drawing
  battery_widget:set({ popup = { drawing = "toggle" } })
  
  if drawing == "off" then
    -- Update detailed battery information
    sbar.exec("pmset -g batt", function(batt_info)
      local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
      local time_label = found and remaining .. "h" or "No estimate"
      remaining_time:set({ label = { string = time_label } })
    end)
    
    -- Get battery health information
    sbar.exec("system_profiler SPPowerDataType | grep 'Cycle Count' | awk '{print $3}'", function(cycles)
      if cycles and cycles ~= "" then
        local cycle_count = tonumber(cycles:gsub("\n", ""))
        local health_status = "Good"
        if cycle_count and cycle_count > 1000 then
          health_status = "Service Recommended"
        elseif cycle_count and cycle_count > 500 then
          health_status = "Fair"
        end
        battery_health:set({ label = { string = health_status } })
      end
    end)
    
    -- Announce popup opening
    sbar.exec('say "Battery details opened"')
  else
    sbar.exec('say "Battery details closed"')
  end
end)

-- Handle hover for additional accessibility feedback
battery_widget:subscribe("mouse.entered", function()
  if not keyboard_nav.get_state().enabled then
    -- Only provide hover feedback if not in keyboard navigation mode
    local current_status = battery_widget:query()
    local percentage = current_status.label.value:gsub("%%", "")
    sbar.exec('say "Battery ' .. percentage .. ' percent"')
  end
end)

-- Add keyboard shortcut for quick access
sbar.add("item", "battery_shortcut_handler", {
  drawing = false,
  script = [[
    # Global keyboard shortcut handler for battery (Cmd+Shift+B)
    # This would be implemented via external hotkey manager
    osascript -e 'tell application "System Events" to keystroke "b" using {command down, shift down}'
  ]]
})

-- Create bracket for visual grouping
sbar.add("bracket", "widgets.battery_accessible.bracket", { 
  battery_widget.name 
}, {
  background = { 
    color = colors.transparent,
    border_width = 0,
    corner_radius = 8
  }
})

-- Add spacing
sbar.add("item", "widgets.battery_accessible.padding", {
  position = "right",
  width = settings.group_paddings
})

-- Initialization
sbar.exec("pmset -g batt", function(batt_info)
  update_battery_display(batt_info)
end)

-- Return widget reference for external configuration
return {
  widget = battery_widget,
  element = battery_element,
  get_status = function()
    return battery_state
  end
}