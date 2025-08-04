local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Enhanced system monitoring widget with multiple metrics
local system_monitor = sbar.add("item", "widgets.system_monitor", {
  position = "right",
  icon = {
    string = "􀧯", -- System monitor icon
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
    color = colors.blue
  },
  label = {
    string = "System",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Medium"],
      size = 10.0,
    },
    color = colors.white
  },
  update_freq = 5,
  popup = {
    align = "center",
    horizontal = true,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/system_monitor.sh"
})

-- CPU metrics in popup
local cpu_item = sbar.add("item", {
  position = "popup." .. system_monitor.name,
  icon = {
    string = "CPU:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "??%",
    width = 60,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Memory metrics in popup
local memory_item = sbar.add("item", {
  position = "popup." .. system_monitor.name,
  icon = {
    string = "RAM:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "?? GB",
    width = 60,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- GPU metrics in popup
local gpu_item = sbar.add("item", {
  position = "popup." .. system_monitor.name,
  icon = {
    string = "GPU:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "??%",
    width = 60,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Thermal metrics in popup
local thermal_item = sbar.add("item", {
  position = "popup." .. system_monitor.name,
  icon = {
    string = "TEMP:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "??°C",
    width = 60,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Disk I/O metrics in popup
local disk_item = sbar.add("item", {
  position = "popup." .. system_monitor.name,
  icon = {
    string = "DISK:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "?? MB/s",
    width = 80,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Power consumption in popup (Apple Silicon Macs)
local power_item = sbar.add("item", {
  position = "popup." .. system_monitor.name,
  icon = {
    string = "POWER:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "?? W",
    width = 60,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Update system metrics
system_monitor:subscribe({"routine", "system_woke"}, function()
  sbar.exec("$CONFIG_DIR/plugins/system_monitor.sh update", function(result)
    local data = {}
    
    -- Parse the result string (format: cpu_percent:memory_gb:gpu_percent:temp_celsius:disk_mbps:power_watts)
    for value in result:gmatch("([^:]+)") do
      table.insert(data, value)
    end
    
    if #data >= 6 then
      local cpu_percent = tonumber(data[1]) or 0
      local memory_gb = data[2] or "??"
      local gpu_percent = tonumber(data[3]) or 0
      local temp_celsius = tonumber(data[4]) or 0
      local disk_mbps = data[5] or "??"
      local power_watts = data[6] or "??"
      
      -- Update main widget based on highest metric
      local max_usage = math.max(cpu_percent, gpu_percent)
      local status_color = colors.green
      local status_text = "OK"
      
      if max_usage > 80 then
        status_color = colors.red
        status_text = "HIGH"
      elseif max_usage > 60 then
        status_color = colors.orange
        status_text = "MED"
      elseif temp_celsius > 75 then
        status_color = colors.yellow
        status_text = "WARM"
      end
      
      system_monitor:set({
        icon = { color = status_color },
        label = { 
          string = status_text,
          color = status_color
        }
      })
      
      -- Update popup items
      cpu_item:set({
        label = { 
          string = cpu_percent .. "%",
          color = cpu_percent > 80 and colors.red or cpu_percent > 60 and colors.orange or colors.green
        }
      })
      
      memory_item:set({
        label = { string = memory_gb .. " GB" }
      })
      
      gpu_item:set({
        label = { 
          string = gpu_percent .. "%",
          color = gpu_percent > 80 and colors.red or gpu_percent > 60 and colors.orange or colors.green
        }
      })
      
      thermal_item:set({
        label = { 
          string = temp_celsius .. "°C",
          color = temp_celsius > 80 and colors.red or temp_celsius > 70 and colors.orange or colors.green
        }
      })
      
      disk_item:set({
        label = { string = disk_mbps .. " MB/s" }
      })
      
      power_item:set({
        label = { string = power_watts .. " W" }
      })
    end
  end)
end)

-- Mouse interactions
system_monitor:subscribe("mouse.clicked", function(env)
  local current_drawing = system_monitor:query().popup.drawing
  system_monitor:set({ popup = { drawing = "toggle" } })
  
  -- If we're opening the popup, refresh the data
  if current_drawing == "off" then
    sbar.exec("$CONFIG_DIR/plugins/system_monitor.sh update")
  end
end)

-- Hover effects with smooth transitions
system_monitor:subscribe("mouse.entered", function(env)
  system_monitor:set({
    background = { 
      color = colors.with_alpha(colors.bg2, 0.8),
      border_width = 1,
      border_color = colors.blue
    }
  })
end)

system_monitor:subscribe("mouse.exited", function(env)
  system_monitor:set({
    background = { 
      color = colors.transparent,
      border_width = 0
    }
  })
end)

-- Background bracket
sbar.add("bracket", "widgets.system_monitor.bracket", { system_monitor.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.system_monitor.padding", {
  position = "right",
  width = settings.group_paddings
})