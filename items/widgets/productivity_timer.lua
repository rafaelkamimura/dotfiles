local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Productivity timer with Pomodoro technique
local productivity_timer = sbar.add("item", "widgets.productivity_timer", {
  position = "right",
  icon = {
    string = "􀐫", -- Timer icon
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
    color = colors.green
  },
  label = {
    string = "25:00",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Medium"],
      size = 12.0,
    },
    color = colors.white
  },
  update_freq = 1, -- Update every second when active
  popup = {
    align = "center",
    horizontal = false,
    drawing = false
  },
  click_script = "$CONFIG_DIR/plugins/productivity_timer.sh click"
})

-- Session type indicator in popup
local session_type = sbar.add("item", {
  position = "popup." .. productivity_timer.name,
  icon = {
    string = "Session:",
    width = 80,
    align = "left",
    font = { size = 12.0, style = settings.font.style_map["Bold"] }
  },
  label = {
    string = "Pomodoro",
    width = 100,
    align = "center",
    font = { 
      family = settings.font.text,
      size = 12.0,
      style = settings.font.style_map["Medium"]
    },
    color = colors.green
  },
})

-- Progress bar in popup
local progress_bar = sbar.add("item", {
  position = "popup." .. productivity_timer.name,
  icon = {
    string = "Progress:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "████████████████████",
    width = 140,
    align = "left",
    font = { 
      family = settings.font.text,
      size = 8.0
    },
    color = colors.green
  },
})

-- Statistics in popup
local stats_today = sbar.add("item", {
  position = "popup." .. productivity_timer.name,
  icon = {
    string = "Today:",
    width = 80,
    align = "left",
    font = { size = 11.0 }
  },
  label = {
    string = "0 sessions",
    width = 100,
    align = "right",
    font = { 
      family = settings.font.numbers,
      size = 11.0 
    }
  },
})

-- Control buttons
local start_stop_button = sbar.add("item", {
  position = "popup." .. productivity_timer.name,
  icon = {
    string = "▶️ Start",
    width = 120,
    align = "center",
    font = { size = 14.0 }
  },
  label = { string = "" },
  click_script = "$CONFIG_DIR/plugins/productivity_timer.sh start_stop"
})

local reset_button = sbar.add("item", {
  position = "popup." .. productivity_timer.name,
  icon = {
    string = "🔄 Reset",
    width = 120,
    align = "center",
    font = { size = 14.0 }
  },
  label = { string = "" },
  click_script = "$CONFIG_DIR/plugins/productivity_timer.sh reset"
})

local skip_button = sbar.add("item", {
  position = "popup." .. productivity_timer.name,
  icon = {
    string = "⏭️ Skip",
    width = 120,
    align = "center",
    font = { size = 14.0 }
  },
  label = { string = "" },
  click_script = "$CONFIG_DIR/plugins/productivity_timer.sh skip"
})

-- Timer state updates
productivity_timer:subscribe("timer_update", function(env)
  local time_left = env.time_left or "25:00"
  local session_type_str = env.session_type or "Pomodoro"
  local is_running = env.is_running == "true"
  local progress = tonumber(env.progress) or 0
  local sessions_today = env.sessions_today or "0"
  
  -- Update main widget
  local timer_color = colors.green
  local timer_icon = "􀐫"
  
  if session_type_str == "Short Break" then
    timer_color = colors.blue
    timer_icon = "􀎬"
  elseif session_type_str == "Long Break" then
    timer_color = colors.yellow
    timer_icon = "􀏀"
  end
  
  if is_running then
    timer_icon = "􀊆" -- Running timer icon
  end
  
  productivity_timer:set({
    icon = {
      string = timer_icon,
      color = timer_color
    },
    label = {
      string = time_left,
      color = is_running and timer_color or colors.grey
    }
  })
  
  -- Update popup items
  session_type:set({
    label = {
      string = session_type_str,
      color = timer_color
    }
  })
  
  -- Create progress bar visualization
  local total_blocks = 20
  local filled_blocks = math.floor(progress * total_blocks)
  local empty_blocks = total_blocks - filled_blocks
  local progress_string = string.rep("█", filled_blocks) .. string.rep("░", empty_blocks)
  
  progress_bar:set({
    label = {
      string = progress_string,
      color = timer_color
    }
  })
  
  stats_today:set({
    label = { string = sessions_today .. " sessions" }
  })
  
  -- Update control buttons
  start_stop_button:set({
    icon = {
      string = is_running and "⏸️ Pause" or "▶️ Start"
    }
  })
end)

-- Handle timer completion notifications
productivity_timer:subscribe("timer_complete", function(env)
  local session_type_str = env.session_type or "Pomodoro"
  local next_session = env.next_session or "Break"
  
  -- Visual feedback for completion
  productivity_timer:set({
    icon = { color = colors.green },
    label = { color = colors.green }
  })
  
  -- Play notification sound and show alert
  sbar.exec("$CONFIG_DIR/plugins/productivity_timer.sh notify_complete")
end)

-- Mouse interactions
productivity_timer:subscribe("mouse.clicked", function(env)
  local current_drawing = productivity_timer:query().popup.drawing
  productivity_timer:set({ popup = { drawing = "toggle" } })
  
  -- If opening popup, refresh timer state
  if current_drawing == "off" then
    sbar.exec("$CONFIG_DIR/plugins/productivity_timer.sh get_state")
  end
end)

-- Hover effects
productivity_timer:subscribe("mouse.entered", function(env)
  productivity_timer:set({
    background = { 
      color = colors.with_alpha(colors.bg2, 0.8),
      border_width = 1,
      border_color = colors.green
    }
  })
  
  -- Show quick preview on hover
  sbar.exec("$CONFIG_DIR/plugins/productivity_timer.sh hover_preview")
end)

productivity_timer:subscribe("mouse.exited", function(env)
  productivity_timer:set({
    background = { 
      color = colors.transparent,
      border_width = 0
    }
  })
end)

-- Initialize timer state
productivity_timer:subscribe("system_woke", function()
  sbar.exec("$CONFIG_DIR/plugins/productivity_timer.sh init")
end)

-- Background bracket
sbar.add("bracket", "widgets.productivity_timer.bracket", { productivity_timer.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.productivity_timer.padding", {
  position = "right",
  width = settings.group_paddings
})