local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local animations = require("helpers.animations")

-- Smart calendar widget with event previews and meeting preparation
local calendar_widget = sbar.add("item", "widgets.calendar_smart", {
  position = "right",
  icon = {
    string = "📅",
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    }
  },
  label = {
    string = os.date("%m/%d"),
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Medium"],
      size = 11.0,
    },
    color = colors.white
  },
  update_freq = 60, -- Update every minute
  popup = {
    align = "center",
    horizontal = false,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/calendar_smart.sh click"
})

-- Current time and date in popup
local current_datetime = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "Now:",
    width = 50,
    align = "left",
    font = { size = 12.0, style = settings.font.style_map["Bold"] }
  },
  label = {
    string = os.date("%A, %B %d • %I:%M %p"),
    width = 200,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 12.0 
    },
    color = colors.blue
  },
})

-- Next event preview
local next_event = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "Next:",
    width = 50,
    align = "left",
    font = { size = 11.0, style = settings.font.style_map["Bold"] }
  },
  label = {
    string = "No upcoming events",
    width = 200,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    },
    color = colors.green
  },
})

-- Event countdown
local event_countdown = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "In:",
    width = 50,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "--",
    width = 200,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    },
    color = colors.yellow
  },
})

-- Meeting preparation reminder
local meeting_prep = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "Prep:",
    width = 50,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "Ready",
    width = 200,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 11.0 
    },
    color = colors.green
  },
})

-- Today's event count
local todays_events = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "Today:",
    width = 50,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "0 events",
    width = 200,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- This week's event count
local weekly_events = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "Week:",
    width = 50,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "0 events",
    width = 200,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Separator for upcoming events
local events_separator = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "═══ Upcoming ═══",
    width = 250,
    align = "center",
    font = { size = 10.0, style = settings.font.style_map["Bold"] },
    color = colors.grey
  },
  label = { string = "" }
})

-- Upcoming events list (next 5 events)
local upcoming_events = {}
for i = 1, 5 do
  local event_item = sbar.add("item", {
    position = "popup." .. calendar_widget.name,
    icon = {
      string = "•",
      width = 20,
      align = "left",
      font = { size = 10.0 }
    },
    label = {
      string = "No events",
      width = 230,
      align = "left",
      font = { 
        family = settings.font.text,
        size = 10.0 
      }
    },
  })
  table.insert(upcoming_events, event_item)
end

-- Time zone information
local timezone_info = sbar.add("item", {
  position = "popup." .. calendar_widget.name,
  icon = {
    string = "🌍",
    width = 20,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = os.date("%Z (%z)"),
    width = 230,
    align = "right",
    font = { 
      family = settings.font.text,
      size = 10.0 
    },
    color = colors.grey
  },
})

-- Calendar updates
calendar_widget:subscribe("calendar_update", function(env)
  local current_date = env.current_date or os.date("%m/%d")
  local current_time = env.current_time or os.date("%I:%M %p")
  local current_day = env.current_day or os.date("%A")
  local next_event_title = env.next_event or "No upcoming events"
  local next_event_time = env.next_event_time or "--"
  local countdown = env.countdown or "--"
  local prep_status = env.prep_status or "Ready"
  local today_count = env.today_events or "0"
  local week_count = env.week_events or "0"
  local timezone = env.timezone or os.date("%Z (%z)")
  
  -- Update main widget
  local is_weekend = (current_day == "Saturday" or current_day == "Sunday")
  local date_color = is_weekend and colors.orange or colors.white
  
  calendar_widget:set({
    label = {
      string = current_date,
      color = date_color
    }
  })
  
  -- Update popup items
  current_datetime:set({
    label = { 
      string = string.format("%s, %s • %s", current_day, os.date("%B %d"), current_time)
    }
  })
  
  -- Next event color coding based on time
  local event_color = colors.green
  if next_event_title ~= "No upcoming events" then
    local countdown_num = tonumber(countdown:match("%d+")) or 999
    local countdown_unit = countdown:match("[a-z]+") or "min"
    
    if countdown_unit == "min" and countdown_num <= 15 then
      event_color = colors.red
    elseif countdown_unit == "min" and countdown_num <= 30 then
      event_color = colors.orange
    elseif countdown_unit == "hour" and countdown_num <= 1 then
      event_color = colors.yellow
    end
  end
  
  next_event:set({
    label = {
      string = next_event_title,
      color = event_color
    }
  })
  
  event_countdown:set({
    label = {
      string = countdown,
      color = event_color
    }
  })
  
  -- Meeting preparation status
  local prep_color = colors.green
  if prep_status == "Needs attention" then
    prep_color = colors.orange
  elseif prep_status == "Not ready" then
    prep_color = colors.red
  end
  
  meeting_prep:set({
    label = {
      string = prep_status,
      color = prep_color
    }
  })
  
  todays_events:set({
    label = { string = today_count .. " events" }
  })
  
  weekly_events:set({
    label = { string = week_count .. " events" }
  })
  
  timezone_info:set({
    label = { string = timezone }
  })
end)

-- Upcoming events update
calendar_widget:subscribe("upcoming_events", function(env)
  for i = 1, 5 do
    local event_data = env["event_" .. i]
    if event_data and event_data ~= "" then
      local parts = {}
      for part in event_data:gmatch("([^|]+)") do
        table.insert(parts, part)
      end
      
      if #parts >= 2 then
        local event_time = parts[1] or ""
        local event_title = parts[2] or "Unnamed event"
        local event_location = parts[3] or ""
        
        local display_text = event_time .. " " .. event_title
        if event_location ~= "" then
          display_text = display_text .. " @ " .. event_location
        end
        
        upcoming_events[i]:set({
          label = { string = display_text }
        })
      else
        upcoming_events[i]:set({
          label = { string = "" }
        })
      end
    else
      upcoming_events[i]:set({
        label = { string = "" }
      })
    end
  end
end)

-- Meeting reminder notifications
calendar_widget:subscribe("meeting_reminder", function(env)
  local event_title = env.event_title or "Meeting"
  local minutes_until = env.minutes_until or "15"
  local event_location = env.event_location or ""
  
  -- Flash the calendar icon
  animations.pulse(calendar_widget, colors.blue, colors.orange, 1.0, 3)
  
  -- Show notification
  local message = string.format("%s in %s minutes", event_title, minutes_until)
  if event_location ~= "" then
    message = message .. " at " .. event_location
  end
  
  sbar.exec(string.format("osascript -e 'display notification \"%s\" with title \"Meeting Reminder\" sound name \"Glass\"'", message))
end)

-- Mouse interactions
calendar_widget:subscribe("mouse.clicked", function(env)
  local current_drawing = calendar_widget:query().popup.drawing
  calendar_widget:set({ popup = { drawing = "toggle" } })
  
  -- If opening popup, refresh calendar data
  if current_drawing == "off" then
    animations.fade_in(calendar_widget, 0.3)
    sbar.exec("$CONFIG_DIR/plugins/calendar_smart.sh update")
  else
    animations.fade_out(calendar_widget, 0.2)
  end
end)

-- Enhanced hover effects
local hover_effect = animations.hover_effect(calendar_widget, colors.with_alpha(colors.blue, 0.6))

calendar_widget:subscribe("mouse.entered", function(env)
  hover_effect.enter()
  
  -- Show quick calendar info on hover
  sbar.exec("$CONFIG_DIR/plugins/calendar_smart.sh hover")
end)

calendar_widget:subscribe("mouse.exited", function(env)
  hover_effect.exit()
end)

-- Daily schedule summary
calendar_widget:subscribe("daily_summary", function(env)
  local busy_hours = env.busy_hours or "0"
  local free_hours = env.free_hours or "8"
  local meeting_count = env.meeting_count or "0"
  
  -- Update icon based on schedule density
  local schedule_icon = "📅"
  if tonumber(busy_hours) > 6 then
    schedule_icon = "🗓️" -- Busy day
  elseif tonumber(meeting_count) > 5 then
    schedule_icon = "📋" -- Many meetings
  end
  
  calendar_widget:set({
    icon = { string = schedule_icon }
  })
end)

-- Initialize calendar
calendar_widget:subscribe("system_woke", function()
  sbar.exec("$CONFIG_DIR/plugins/calendar_smart.sh init")
end)

-- Regular time updates
calendar_widget:subscribe("routine", function()
  sbar.exec("$CONFIG_DIR/plugins/calendar_smart.sh time_update")
end)

-- Background bracket
sbar.add("bracket", "widgets.calendar_smart.bracket", { calendar_widget.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.calendar_smart.padding", {
  position = "right",
  width = settings.group_paddings
})