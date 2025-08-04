-- Accessible animation framework for SketchyBar
-- Respects system motion preferences and provides reduced motion alternatives
-- Complies with WCAG 2.1 Guideline 2.3.3 (Animation from Interactions)

local colors = require("colors")

local animations_accessible = {}

-- System motion preference detection
local motion_preferences = {
  reduce_motion = false,
  disable_animations = false,
  reduce_transparency = false,
  prefer_cross_fade = false
}

-- Function to detect macOS motion preferences
local function update_motion_preferences()
  -- Check for reduce motion preference
  sbar.exec('defaults read com.apple.universalaccess reduceMotion 2>/dev/null || echo "0"', function(result)
    motion_preferences.reduce_motion = result:match("1") ~= nil
  end)
  
  -- Check for reduce transparency (affects fade animations)
  sbar.exec('defaults read com.apple.universalaccess reduceTransparency 2>/dev/null || echo "0"', function(result)
    motion_preferences.reduce_transparency = result:match("1") ~= nil
  end)
  
  -- Check for differentiate without color (affects animations that rely on color alone)
  sbar.exec('defaults read com.apple.universalaccess differentiateWithoutColor 2>/dev/null || echo "0"', function(result)
    motion_preferences.prefer_cross_fade = result:match("1") ~= nil
  end)
end

-- Initialize motion preferences on load
update_motion_preferences()

-- Refresh preferences periodically (every 30 seconds)
sbar.exec("while true; do sleep 30; echo 'refresh_motion_prefs'; done", function()
  update_motion_preferences()
end)

-- Safe animation wrapper that respects motion preferences
local function safe_animate(animation_func, reduced_motion_alternative, ...)
  if motion_preferences.reduce_motion or motion_preferences.disable_animations then
    if reduced_motion_alternative then
      reduced_motion_alternative(...)
    end
  else
    animation_func(...)
  end
end

-- Accessible easing functions (no problematic bouncing or elastic effects)
animations_accessible.easing = {
  -- Linear easing (always safe)
  linear = function(t)
    return t
  end,
  
  -- Gentle ease functions (reduced intensity)
  ease_in = function(t)
    return t * t
  end,
  
  ease_out = function(t)
    return 1 - (1 - t) * (1 - t)
  end,
  
  ease_in_out = function(t)
    if t < 0.5 then
      return 2 * t * t
    else
      return 1 - 2 * (1 - t) * (1 - t)
    end
  end,
  
  -- Removed problematic easing functions:
  -- - bounce (can trigger vestibular disorders)
  -- - elastic (rapid oscillations)
  -- - back (sudden direction changes)
}

-- Reduced motion color interpolation (instant for reduce motion users)
animations_accessible.interpolate_color = function(start_color, end_color, progress)
  if motion_preferences.reduce_motion then
    -- Instant transition for reduced motion users
    return progress >= 1.0 and end_color or start_color
  end
  
  -- Standard color interpolation for others
  local start_a = (start_color >> 24) & 0xFF
  local start_r = (start_color >> 16) & 0xFF
  local start_g = (start_color >> 8) & 0xFF
  local start_b = start_color & 0xFF
  
  local end_a = (end_color >> 24) & 0xFF
  local end_r = (end_color >> 16) & 0xFF
  local end_g = (end_color >> 8) & 0xFF
  local end_b = end_color & 0xFF
  
  local new_a = math.floor(start_a + (end_a - start_a) * progress)
  local new_r = math.floor(start_r + (end_r - start_r) * progress)
  local new_g = math.floor(start_g + (end_g - start_g) * progress)
  local new_b = math.floor(start_b + (end_b - start_b) * progress)
  
  return (new_a << 24) | (new_r << 16) | (new_g << 8) | new_b
end

-- Safe color transition with instant fallback
animations_accessible.color_transition = function(widget, property_path, start_color, end_color, duration, easing_func, callback)
  local reduced_motion_alternative = function()
    -- Instant transition for reduced motion users
    local update_table = {}
    local keys = {}
    for key in property_path:gmatch("([^.]+)") do
      table.insert(keys, key)
    end
    
    if #keys == 1 then
      update_table[keys[1]] = end_color
    elseif #keys == 2 then
      update_table[keys[1]] = { [keys[2]] = end_color }
    else
      update_table[keys[1]] = { [keys[2]] = end_color }
    end
    
    widget:set(update_table)
    if callback then callback() end
  end
  
  safe_animate(function()
    -- Original animation logic (simplified for safety)
    local start_time = os.clock()
    local easing = easing_func or animations_accessible.easing.ease_out
    
    local function update_color()
      local current_time = os.clock()
      local elapsed = current_time - start_time
      local progress = math.min(elapsed / duration, 1.0)
      
      local eased_progress = easing(progress)
      local current_color = animations_accessible.interpolate_color(start_color, end_color, eased_progress)
      
      local update_table = {}
      local keys = {}
      for key in property_path:gmatch("([^.]+)") do
        table.insert(keys, key)
      end
      
      if #keys == 1 then
        update_table[keys[1]] = current_color
      elseif #keys == 2 then
        update_table[keys[1]] = { [keys[2]] = current_color }
      else
        update_table[keys[1]] = { [keys[2]] = current_color }
      end
      
      widget:set(update_table)
      
      if progress < 1.0 then
        -- Slower refresh rate for reduced CPU usage
        sbar.exec("sleep 0.033 && echo 'continue'", function()
          update_color()
        end)
      else
        if callback then callback() end
      end
    end
    
    update_color()
  end, reduced_motion_alternative)
end

-- Safe fade in (respects transparency preferences)
animations_accessible.fade_in = function(widget, duration, easing_func, callback)
  local duration = duration or 0.2  -- Reduced duration
  local easing = easing_func or animations_accessible.easing.ease_out
  
  if motion_preferences.reduce_transparency then
    -- Skip transparency effects, use solid backgrounds
    widget:set({ background = { color = colors.bg1 } })
    if callback then callback() end
    return
  end
  
  widget:set({ background = { color = colors.transparent } })
  
  animations_accessible.color_transition(
    widget, 
    "background.color", 
    colors.transparent, 
    colors.bg1, 
    duration, 
    easing, 
    callback
  )
end

-- Safe fade out
animations_accessible.fade_out = function(widget, duration, easing_func, callback)
  local duration = duration or 0.2  -- Reduced duration
  local easing = easing_func or animations_accessible.easing.ease_in
  
  if motion_preferences.reduce_transparency then
    -- Instant hide for transparency-sensitive users
    widget:set({ background = { color = colors.transparent } })
    if callback then callback() end
    return
  end
  
  animations_accessible.color_transition(
    widget, 
    "background.color", 
    colors.bg1, 
    colors.transparent, 
    duration, 
    easing, 
    callback
  )
end

-- Accessible status indication (no flashing)
animations_accessible.status_change = function(widget, new_color, callback)
  -- For reduced motion users, provide instant feedback
  if motion_preferences.reduce_motion then
    widget:set({ icon = { color = new_color } })
    if callback then callback() end
    return
  end
  
  -- Gentle color transition for others
  animations_accessible.color_transition(
    widget,
    "icon.color",
    widget:query().icon.color or colors.grey,
    new_color,
    0.3,  -- Gentle transition
    animations_accessible.easing.ease_out,
    callback
  )
end

-- Hover effect with accessibility considerations
animations_accessible.hover_effect = function(widget, hover_color, normal_color)
  local hover_color = hover_color or colors.with_alpha(colors.bg2, 0.8)
  local normal_color = normal_color or colors.transparent
  
  return {
    enter = function()
      if motion_preferences.reduce_motion then
        widget:set({ background = { color = hover_color } })
      else
        animations_accessible.color_transition(
          widget,
          "background.color",
          normal_color,
          hover_color,
          0.15,  -- Very quick for responsiveness
          animations_accessible.easing.ease_out
        )
      end
    end,
    
    exit = function()
      if motion_preferences.reduce_motion then
        widget:set({ background = { color = normal_color } })
      else
        animations_accessible.color_transition(
          widget,
          "background.color",
          hover_color,
          normal_color,
          0.2,
          animations_accessible.easing.ease_out
        )
      end
    end
  }
end

-- Safe loading indicator (no rapid flashing)
animations_accessible.loading = function(widget, style, callback)
  local style = style or "gentle_pulse"
  local is_loading = true
  
  local stop_loading = function()
    is_loading = false
    widget:set({ icon = { color = colors.grey } })
    if callback then callback() end
  end
  
  if motion_preferences.reduce_motion then
    -- Static loading indicator for motion-sensitive users
    widget:set({ 
      icon = { color = colors.blue },
      label = { string = "Loading..." }  -- Text alternative
    })
    return stop_loading
  end
  
  -- Gentle pulse animation
  local function gentle_pulse()
    if not is_loading then return end
    
    animations_accessible.color_transition(
      widget,
      "icon.color",
      colors.grey,
      colors.blue,
      1.0,  -- Slow transition
      animations_accessible.easing.ease_in_out,
      function()
        if not is_loading then return end
        animations_accessible.color_transition(
          widget,
          "icon.color",
          colors.blue,
          colors.grey,
          1.0,  -- Slow transition back
          animations_accessible.easing.ease_in_out,
          gentle_pulse
        )
      end
    )
  end
  
  gentle_pulse()
  return stop_loading
end

-- Notification animation (no seizure-inducing flashing)
animations_accessible.notify = function(widget, type, callback)
  local type = type or "info"
  local colors_map = {
    success = colors.green,
    warning = colors.yellow,
    error = colors.red,
    info = colors.blue
  }
  
  local notification_color = colors_map[type] or colors.blue
  
  if motion_preferences.reduce_motion then
    -- Static notification for motion-sensitive users
    widget:set({ 
      background = { color = notification_color },
      label = { string = type:upper() }  -- Text indicator
    })
    
    -- Auto-hide after delay
    sbar.exec("sleep 3", function()
      widget:set({ background = { color = colors.transparent } })
      if callback then callback() end
    end)
    return
  end
  
  -- Gentle highlight animation
  animations_accessible.color_transition(
    widget,
    "background.color",
    colors.transparent,
    notification_color,
    0.3,
    animations_accessible.easing.ease_out,
    function()
      sbar.exec("sleep 2", function()  -- Show for 2 seconds
        animations_accessible.color_transition(
          widget,
          "background.color", 
          notification_color,
          colors.transparent,
          0.5,
          animations_accessible.easing.ease_in,
          callback
        )
      end)
    end
  )
end

-- Chain animations with accessibility breaks
animations_accessible.chain = function(animation_list, callback)
  if motion_preferences.reduce_motion then
    -- Execute all instantly for reduced motion users
    for _, anim in ipairs(animation_list) do
      if anim.instant_func then
        anim.instant_func()
      end
    end
    if callback then callback() end
    return
  end
  
  local current_index = 1
  
  local function run_next()
    if current_index <= #animation_list then
      local anim = animation_list[current_index]
      current_index = current_index + 1
      
      anim.func(table.unpack(anim.args or {}), run_next)
    else
      if callback then callback() end
    end
  end
  
  run_next()
end

-- Utility function to disable all animations
animations_accessible.disable_all = function()
  motion_preferences.disable_animations = true
end

-- Utility function to enable animations (respecting system preferences)
animations_accessible.enable_all = function()
  motion_preferences.disable_animations = false
  update_motion_preferences()  -- Refresh system preferences
end

-- Get current motion preferences (for widget configuration)
animations_accessible.get_motion_preferences = function()
  return motion_preferences
end

return animations_accessible