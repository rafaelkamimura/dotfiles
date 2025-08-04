local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Enhanced battery widget with health metrics and power trends
local battery_enhanced = sbar.add("item", "widgets.battery_enhanced", {
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 18.0,
    }
  },
  label = { 
    font = { family = settings.font.numbers },
    width = 40,
    align = "right"
  },
  update_freq = 30,
  popup = { 
    align = "center",
    horizontal = false,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/battery_enhanced.sh click"
})

-- Battery health indicator in popup
local health_indicator = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Health:",
    width = 80,
    align = "left",
    font = { size = 12.0, style = settings.font.style_map["Bold"] }
  },
  label = {
    string = "Normal",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 12.0 
    },
    color = colors.green
  },
})

-- Cycle count in popup
local cycle_count = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Cycles:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "0 / 1000",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Battery temperature in popup
local temperature = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Temp:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "??°C",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Power consumption in popup
local power_draw = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Power:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "0.0W",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Time remaining in popup
local time_remaining = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Time:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "??:??h",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Capacity information in popup
local capacity_info = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Capacity:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "100%",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Power source in popup
local power_source = sbar.add("item", {
  position = "popup." .. battery_enhanced.name,
  icon = {
    string = "Source:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "Battery",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    }
  },
})

-- Power trend graph (small inline graph)
local power_trend = sbar.add("graph", "battery.power_trend", 50, {
  position = "popup." .. battery_enhanced.name,
  graph = { 
    color = colors.yellow,
    fill_color = colors.with_alpha(colors.yellow, 0.2),
    line_width = 1.5
  },
  background = {
    height = 30,
    color = colors.with_alpha(colors.bg2, 0.5),
    border_width = 1,
    border_color = colors.with_alpha(colors.yellow, 0.3),
    corner_radius = 4
  },
  icon = {
    string = "Power Trend",
    font = { size = 9.0 },
    color = colors.yellow,
    y_offset = -10
  },
  label = {
    string = "",
    y_offset = 10
  }
})

-- Battery status updates
battery_enhanced:subscribe({"routine", "power_source_change", "system_woke"}, function()
  sbar.exec("$CONFIG_DIR/plugins/battery_enhanced.sh update", function(result)
    local data = {}
    
    -- Parse result (format: percentage:charging:health:cycles:temp:power:time:capacity:source)
    for value in result:gmatch("([^:]+)") do
      table.insert(data, value)
    end
    
    if #data >= 9 then
      local percentage = tonumber(data[1]) or 0
      local is_charging = data[2] == "true"
      local health_status = data[3] or "Unknown"
      local cycles = data[4] or "0"
      local temp_c = data[5] or "??"
      local power_watts = tonumber(data[6]) or 0
      local time_left = data[7] or "??:??"
      local max_capacity = data[8] or "100"
      local source = data[9] or "Battery"
      
      -- Update main widget icon and color
      local icon = icons.battery._100
      local color = colors.green
      
      if is_charging then
        icon = icons.battery.charging
        color = colors.blue
      else
        if percentage <= 10 then
          icon = icons.battery._0
          color = colors.red
        elseif percentage <= 25 then
          icon = icons.battery._25
          color = colors.orange
        elseif percentage <= 50 then
          icon = icons.battery._50
          color = colors.yellow
        elseif percentage <= 75 then
          icon = icons.battery._75
          color = colors.green
        else
          icon = icons.battery._100
          color = colors.green
        end
      end
      
      battery_enhanced:set({
        icon = {
          string = icon,
          color = color
        },
        label = {
          string = percentage .. "%",
          color = color
        }
      })
      
      -- Update popup items
      local health_color = colors.green
      if health_status == "Replace Soon" or health_status == "Replace Now" then
        health_color = colors.red
      elseif health_status == "Service Battery" then
        health_color = colors.orange
      end
      
      health_indicator:set({
        label = {
          string = health_status,
          color = health_color
        }
      })
      
      -- Color code cycle count (typical max is 1000 cycles)
      local cycle_num = tonumber(cycles) or 0
      local cycle_color = colors.green
      if cycle_num > 800 then
        cycle_color = colors.red
      elseif cycle_num > 600 then
        cycle_color = colors.orange
      elseif cycle_num > 400 then
        cycle_color = colors.yellow
      end
      
      cycle_count:set({
        label = {
          string = cycles .. " / 1000",
          color = cycle_color
        }
      })
      
      -- Temperature color coding
      local temp_num = tonumber(temp_c) or 30
      local temp_color = colors.green
      if temp_num > 45 then
        temp_color = colors.red
      elseif temp_num > 40 then
        temp_color = colors.orange
      elseif temp_num > 35 then
        temp_color = colors.yellow
      end
      
      temperature:set({
        label = {
          string = temp_c .. "°C",
          color = temp_color
        }
      })
      
      -- Power draw color coding
      local power_color = colors.green
      if power_watts > 15 then
        power_color = colors.red
      elseif power_watts > 10 then
        power_color = colors.orange
      elseif power_watts > 5 then
        power_color = colors.yellow
      end
      
      power_draw:set({
        label = {
          string = string.format("%.1fW", power_watts),
          color = power_color
        }
      })
      
      time_remaining:set({
        label = { string = time_left }
      })
      
      capacity_info:set({
        label = {
          string = max_capacity .. "%",
          color = tonumber(max_capacity) < 80 and colors.orange or colors.green
        }
      })
      
      power_source:set({
        label = {
          string = source,
          color = is_charging and colors.blue or colors.white
        }
      })
      
      -- Update power trend graph
      local normalized_power = math.min(power_watts / 20, 1.0) -- Normalize to 20W max
      power_trend:push({ normalized_power })
    end
  end)
end)

-- Mouse interactions
battery_enhanced:subscribe("mouse.clicked", function(env)
  local current_drawing = battery_enhanced:query().popup.drawing
  battery_enhanced:set({ popup = { drawing = "toggle" } })
  
  -- If opening popup, refresh battery data
  if current_drawing == "off" then
    sbar.exec("$CONFIG_DIR/plugins/battery_enhanced.sh update")
  end
end)

-- Hover effects
battery_enhanced:subscribe("mouse.entered", function(env)
  battery_enhanced:set({
    background = { 
      color = colors.with_alpha(colors.bg2, 0.8),
      border_width = 1,
      border_color = colors.green
    }
  })
  
  -- Show quick battery info on hover
  sbar.exec("$CONFIG_DIR/plugins/battery_enhanced.sh hover")
end)

battery_enhanced:subscribe("mouse.exited", function(env)
  battery_enhanced:set({
    background = { 
      color = colors.transparent,
      border_width = 0
    }
  })
end)

-- Low battery warnings
battery_enhanced:subscribe("battery_warning", function(env)
  local level = env.level or "unknown"
  local percentage = tonumber(env.percentage) or 100
  
  -- Flash the battery icon for warnings
  battery_enhanced:set({
    icon = { color = colors.red }
  })
  
  -- Reset color after flash
  sbar.exec("sleep 0.5 && sketchybar --set widgets.battery_enhanced icon.color=0xff" .. string.format("%06x", colors.orange))
end)

-- Background bracket
sbar.add("bracket", "widgets.battery_enhanced.bracket", { battery_enhanced.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.battery_enhanced.padding", {
  position = "right",
  width = settings.group_paddings
})