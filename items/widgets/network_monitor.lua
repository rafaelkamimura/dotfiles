local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Enhanced network monitoring widget with real-time graphs
local network_monitor = sbar.add("item", "widgets.network_monitor", {
  position = "right",
  icon = {
    string = icons.wifi.connected,
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
    color = colors.green
  },
  label = {
    string = "0↑ 0↓",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Medium"],
      size = 10.0,
    },
    color = colors.white
  },
  update_freq = 2,
  popup = {
    align = "center",
    horizontal = false,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/network_monitor.sh click"
})

-- Upload speed graph in popup
local upload_graph = sbar.add("graph", "network.upload_graph", 60, {
  position = "popup." .. network_monitor.name,
  graph = { 
    color = colors.green,
    fill_color = colors.with_alpha(colors.green, 0.3),
    line_width = 2.0
  },
  background = {
    height = 40,
    color = colors.with_alpha(colors.bg2, 0.8),
    border_width = 1,
    border_color = colors.with_alpha(colors.green, 0.5),
    corner_radius = 6
  },
  icon = {
    string = "Upload ↑",
    font = { size = 10.0 },
    color = colors.green,
    y_offset = -15
  },
  label = {
    string = "0 KB/s",
    font = { 
      family = settings.font.numbers,
      size = 9.0 
    },
    color = colors.green,
    y_offset = 15
  }
})

-- Download speed graph in popup
local download_graph = sbar.add("graph", "network.download_graph", 60, {
  position = "popup." .. network_monitor.name,
  graph = { 
    color = colors.blue,
    fill_color = colors.with_alpha(colors.blue, 0.3),
    line_width = 2.0
  },
  background = {
    height = 40,
    color = colors.with_alpha(colors.bg2, 0.8),
    border_width = 1,
    border_color = colors.with_alpha(colors.blue, 0.5),
    corner_radius = 6
  },
  icon = {
    string = "Download ↓",
    font = { size = 10.0 },
    color = colors.blue,
    y_offset = -15
  },
  label = {
    string = "0 KB/s",
    font = { 
      family = settings.font.numbers,
      size = 9.0 
    },
    color = colors.blue,
    y_offset = 15
  }
})

-- Connection information in popup
local connection_info = sbar.add("item", {
  position = "popup." .. network_monitor.name,
  icon = {
    string = "Connection:",
    width = 80,
    align = "left",
    font = { size = 11.0, style = settings.font.style_map["Bold"] }
  },
  label = {
    string = "WiFi Connected",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    }
  },
})

-- Signal quality in popup
local signal_quality = sbar.add("item", {
  position = "popup." .. network_monitor.name,
  icon = {
    string = "Signal:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "●●●●○",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    },
    color = colors.green
  },
})

-- IP address in popup
local ip_address = sbar.add("item", {
  position = "popup." .. network_monitor.name,
  icon = {
    string = "IP:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "192.168.1.100",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Ping latency in popup
local ping_latency = sbar.add("item", {
  position = "popup." .. network_monitor.name,
  icon = {
    string = "Ping:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "? ms",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Data usage today in popup
local data_usage = sbar.add("item", {
  position = "popup." .. network_monitor.name,
  icon = {
    string = "Today:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "0 MB",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Network speed updates
network_monitor:subscribe("network_update", function(env)
  local upload_speed = tonumber(env.upload_speed) or 0
  local download_speed = tonumber(env.download_speed) or 0
  local upload_unit = env.upload_unit or "KB/s"
  local download_unit = env.download_unit or "KB/s"
  local connection_type = env.connection_type or "WiFi"
  local signal_strength = tonumber(env.signal_strength) or 0
  local is_connected = env.is_connected == "true"
  local ip_addr = env.ip_address or "N/A"
  local ping_ms = env.ping_latency or "?"
  local total_usage = env.data_usage_today or "0 MB"
  
  -- Update main widget
  local status_icon = icons.wifi.connected
  local status_color = colors.green
  
  if not is_connected then
    status_icon = icons.wifi.disconnected
    status_color = colors.red
  elseif connection_type == "Ethernet" then
    status_icon = "􀌗" -- Ethernet icon
    status_color = colors.blue
  end
  
  -- Format speed display
  local speed_display = string.format("%.0f%s↑ %.0f%s↓", 
    upload_speed, upload_unit:sub(1,1),
    download_speed, download_unit:sub(1,1))
  
  network_monitor:set({
    icon = {
      string = status_icon,
      color = status_color
    },
    label = {
      string = speed_display,
      color = colors.white
    }
  })
  
  -- Update graphs (normalize speeds to 0-1 range for better visualization)
  local max_speed = 10000 -- Assume max 10 MB/s for scaling
  local upload_normalized = math.min(upload_speed / max_speed, 1.0)
  local download_normalized = math.min(download_speed / max_speed, 1.0)
  
  upload_graph:push({ upload_normalized })
  download_graph:push({ download_normalized })
  
  -- Update graph labels
  upload_graph:set({
    label = { string = string.format("%.1f %s", upload_speed, upload_unit) }
  })
  
  download_graph:set({
    label = { string = string.format("%.1f %s", download_speed, download_unit) }
  })
  
  -- Update connection info
  connection_info:set({
    label = { 
      string = connection_type .. (is_connected and " Connected" or " Disconnected"),
      color = is_connected and colors.green or colors.red
    }
  })
  
  -- Update signal quality (show as dots)
  local signal_dots = ""
  local max_dots = 5
  local filled_dots = math.floor((signal_strength / 100) * max_dots)
  
  for i = 1, max_dots do
    if i <= filled_dots then
      signal_dots = signal_dots .. "●"
    else
      signal_dots = signal_dots .. "○"
    end
  end
  
  local signal_color = colors.green
  if signal_strength < 30 then
    signal_color = colors.red
  elseif signal_strength < 60 then
    signal_color = colors.orange
  end
  
  signal_quality:set({
    label = {
      string = signal_dots .. " " .. signal_strength .. "%",
      color = signal_color
    }
  })
  
  -- Update other info
  ip_address:set({
    label = { string = ip_addr }
  })
  
  local ping_color = colors.green
  local ping_num = tonumber(ping_ms) or 999
  if ping_num > 100 then
    ping_color = colors.red
  elseif ping_num > 50 then
    ping_color = colors.orange
  end
  
  ping_latency:set({
    label = { 
      string = ping_ms .. " ms",
      color = ping_color
    }
  })
  
  data_usage:set({
    label = { string = total_usage }
  })
end)

-- Mouse interactions
network_monitor:subscribe("mouse.clicked", function(env)
  local current_drawing = network_monitor:query().popup.drawing
  network_monitor:set({ popup = { drawing = "toggle" } })
  
  -- If opening popup, refresh network data
  if current_drawing == "off" then
    sbar.exec("$CONFIG_DIR/plugins/network_monitor.sh update")
  end
end)

-- Hover effects
network_monitor:subscribe("mouse.entered", function(env)
  network_monitor:set({
    background = { 
      color = colors.with_alpha(colors.bg2, 0.8),
      border_width = 1,
      border_color = colors.blue
    }
  })
end)

network_monitor:subscribe("mouse.exited", function(env)
  network_monitor:set({
    background = { 
      color = colors.transparent,
      border_width = 0
    }
  })
end)

-- Initialize network monitoring
network_monitor:subscribe("system_woke", function()
  sbar.exec("$CONFIG_DIR/plugins/network_monitor.sh init")
end)

-- Background bracket
sbar.add("bracket", "widgets.network_monitor.bracket", { network_monitor.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.network_monitor.padding", {
  position = "right",
  width = settings.group_paddings
})