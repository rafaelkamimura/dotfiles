local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local animations = require("helpers.animations")

-- Comprehensive weather widget with forecasts, air quality, and alerts
local weather_widget = sbar.add("item", "widgets.weather_comprehensive", {
  position = "right",
  icon = {
    string = "🌤️",
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    }
  },
  label = {
    string = "Loading...",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Medium"],
      size = 11.0,
    },
    color = colors.white
  },
  update_freq = 600, -- Update every 10 minutes
  popup = {
    align = "center",
    horizontal = false,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/weather_comprehensive.sh click"
})

-- Current conditions in popup
local current_conditions = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "Now:",
    width = 60,
    align = "left",
    font = { size = 12.0, style = settings.font.style_map["Bold"] }
  },
  label = {
    string = "22°C Sunny",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 12.0 
    }
  },
})

-- Feels like temperature
local feels_like = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "Feels:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "24°C",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Humidity and pressure
local humidity_pressure = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "Humidity:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "65% • 1013mb",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Wind information
local wind_info = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "Wind:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "5 km/h NE",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    }
  },
})

-- UV Index
local uv_index = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "UV Index:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "3 Moderate",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    }
  },
})

-- Air Quality Index
local air_quality = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "Air Quality:",
    width = 60,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "Good",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    },
    color = colors.green
  },
})

-- Separator for forecast
local forecast_separator = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "═══ Forecast ═══",
    width = 180,
    align = "center",
    font = { size = 10.0, style = settings.font.style_map["Bold"] },
    color = colors.grey
  },
  label = { string = "" }
})

-- Hourly forecast (next 6 hours)
local hourly_forecasts = {}
for i = 1, 6 do
  local hour_item = sbar.add("item", {
    position = "popup." .. weather_widget.name,
    icon = {
      string = "+1h:",
      width = 40,
      align = "left",
      font = { size = 10.0 }
    },
    label = {
      string = "🌤️ 21°",
      width = 80,
      align = "right",
      font = { 
        family = settings.font.text,
        size = 10.0 
      }
    },
  })
  table.insert(hourly_forecasts, hour_item)
end

-- Daily forecast separator
local daily_separator = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "═══ 3-Day ═══",
    width = 180,
    align = "center",
    font = { size = 10.0, style = settings.font.style_map["Bold"] },
    color = colors.grey
  },
  label = { string = "" }
})

-- 3-day forecast
local daily_forecasts = {}
for i = 1, 3 do
  local day_item = sbar.add("item", {
    position = "popup." .. weather_widget.name,
    icon = {
      string = "Today:",
      width = 50,
      align = "left",
      font = { size = 10.0 }
    },
    label = {
      string = "⛅ 25°/15°",
      width = 90,
      align = "right",
      font = { 
        family = settings.font.text,
        size = 10.0 
      }
    },
  })
  table.insert(daily_forecasts, day_item)
end

-- Weather alerts (if any)
local weather_alert = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "⚠️ Alert:",
    width = 60,
    align = "left",
    font = { size = 11.0 },
    color = colors.orange
  },
  label = {
    string = "None",
    width = 120,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    }
  },
})

-- Location information
local location_info = sbar.add("item", {
  position = "popup." .. weather_widget.name,
  icon = {
    string = "📍",
    width = 20,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "Auto-detected",
    width = 160,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 10.0 
    },
    color = colors.grey
  },
})

-- Weather data updates
weather_widget:subscribe("weather_update", function(env)
  local temp = env.temperature or "??"
  local condition = env.condition or "Unknown"
  local icon = env.weather_icon or "🌤️"
  local feels_temp = env.feels_like or "??"
  local humidity = env.humidity or "??"
  local pressure = env.pressure or "????"
  local wind_speed = env.wind_speed or "??"
  local wind_dir = env.wind_direction or "??"
  local uv = env.uv_index or "??"
  local uv_desc = env.uv_description or ""
  local aqi = env.air_quality_index or "??"
  local aqi_desc = env.air_quality_desc or "Unknown"
  local location = env.location or "Unknown"
  local alert = env.weather_alert or "None"
  
  -- Update main widget
  local temp_color = colors.white
  local temp_num = tonumber(temp:gsub("°C", "")) or 20
  
  if temp_num > 30 then
    temp_color = colors.red
  elseif temp_num > 25 then
    temp_color = colors.orange
  elseif temp_num < 0 then
    temp_color = colors.blue
  elseif temp_num < 10 then
    temp_color = colors.blue
  end
  
  weather_widget:set({
    icon = { string = icon },
    label = { 
      string = temp,
      color = temp_color
    }
  })
  
  -- Update popup items
  current_conditions:set({
    label = { string = temp .. " " .. condition }
  })
  
  feels_like:set({
    label = { string = feels_temp }
  })
  
  humidity_pressure:set({
    label = { string = humidity .. "% • " .. pressure .. "mb" }
  })
  
  wind_info:set({
    label = { string = wind_speed .. " " .. wind_dir }
  })
  
  -- UV Index color coding
  local uv_num = tonumber(uv) or 0
  local uv_color = colors.green
  if uv_num >= 8 then
    uv_color = colors.red
  elseif uv_num >= 6 then
    uv_color = colors.orange
  elseif uv_num >= 3 then
    uv_color = colors.yellow
  end
  
  uv_index:set({
    label = { 
      string = uv .. " " .. uv_desc,
      color = uv_color
    }
  })
  
  -- Air Quality color coding
  local aqi_color = colors.green
  if aqi_desc == "Unhealthy" or aqi_desc == "Hazardous" then
    aqi_color = colors.red
  elseif aqi_desc == "Unhealthy for Sensitive" then
    aqi_color = colors.orange
  elseif aqi_desc == "Moderate" then
    aqi_color = colors.yellow
  end
  
  air_quality:set({
    label = {
      string = aqi_desc,
      color = aqi_color
    }
  })
  
  -- Update location
  location_info:set({
    label = { string = location }
  })
  
  -- Update weather alert
  if alert ~= "None" then
    weather_alert:set({
      label = { 
        string = alert,
        color = colors.orange
      }
    })
    
    -- Animate alert for attention
    animations.pulse(weather_alert, colors.orange, colors.red, 0.8, 2)
  else
    weather_alert:set({
      label = { 
        string = "None",
        color = colors.green
      }
    })
  end
end)

-- Hourly forecast updates
weather_widget:subscribe("hourly_forecast", function(env)
  for i = 1, 6 do
    local hour_data = env["hour_" .. i]
    if hour_data then
      local parts = {}
      for part in hour_data:gmatch("([^|]+)") do
        table.insert(parts, part)
      end
      
      if #parts >= 3 then
        local time_label = parts[1] or ("+1h:")
        local icon_temp = (parts[2] or "🌤️") .. " " .. (parts[3] or "??°")
        
        hourly_forecasts[i]:set({
          icon = { string = time_label },
          label = { string = icon_temp }
        })
      end
    end
  end
end)

-- Daily forecast updates
weather_widget:subscribe("daily_forecast", function(env)
  local days = {"Today:", "Tomorrow:", "Day 3:"}
  
  for i = 1, 3 do
    local day_data = env["day_" .. i]
    if day_data then
      local parts = {}
      for part in day_data:gmatch("([^|]+)") do
        table.insert(parts, part)
      end
      
      if #parts >= 4 then
        local day_name = days[i]
        local icon = parts[2] or "🌤️"
        local high_temp = parts[3] or "??"
        local low_temp = parts[4] or "??"
        local forecast_text = icon .. " " .. high_temp .. "°/" .. low_temp .. "°"
        
        daily_forecasts[i]:set({
          icon = { string = day_name },
          label = { string = forecast_text }
        })
      end
    end
  end
end)

-- Mouse interactions
weather_widget:subscribe("mouse.clicked", function(env)
  local current_drawing = weather_widget:query().popup.drawing
  weather_widget:set({ popup = { drawing = "toggle" } })
  
  -- If opening popup, refresh weather data
  if current_drawing == "off" then
    -- Animate popup appearance
    animations.fade_in(weather_widget, 0.3)
    sbar.exec("$CONFIG_DIR/plugins/weather_comprehensive.sh update")
  else
    animations.fade_out(weather_widget, 0.2)
  end
end)

-- Enhanced hover effects with animations
local hover_effect = animations.hover_effect(weather_widget, colors.with_alpha(colors.blue, 0.6))

weather_widget:subscribe("mouse.entered", function(env)
  hover_effect.enter()
  
  -- Show quick weather summary on hover
  sbar.exec("$CONFIG_DIR/plugins/weather_comprehensive.sh hover")
end)

weather_widget:subscribe("mouse.exited", function(env)
  hover_effect.exit()
end)

-- Weather alert notifications
weather_widget:subscribe("weather_alert", function(env)
  local alert_type = env.alert_type or "info"
  local alert_message = env.alert_message or "Weather alert"
  
  -- Animate alert indication
  if alert_type == "severe" then
    animations.pulse(weather_widget, colors.red, colors.orange, 1.0, 5)
  else
    animations.pulse(weather_widget, colors.orange, colors.yellow, 0.8, 3)
  end
end)

-- Initialize weather data
weather_widget:subscribe("system_woke", function()
  sbar.exec("$CONFIG_DIR/plugins/weather_comprehensive.sh init")
end)

-- Background bracket
sbar.add("bracket", "widgets.weather_comprehensive.bracket", { weather_widget.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.weather_comprehensive.padding", {
  position = "right",
  width = settings.group_paddings
})