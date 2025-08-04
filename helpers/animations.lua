-- Animation framework for SketchyBar widgets
-- Provides smooth transitions, easing functions, and animation utilities

local colors = require("colors")

local animations = {}

-- Easing functions for smooth animations
animations.easing = {
  -- Linear easing (no acceleration)
  linear = function(t)
    return t
  end,
  
  -- Ease in (slow start)
  ease_in = function(t)
    return t * t
  end,
  
  -- Ease out (slow end)
  ease_out = function(t)
    return 1 - (1 - t) * (1 - t)
  end,
  
  -- Ease in-out (slow start and end)
  ease_in_out = function(t)
    if t < 0.5 then
      return 2 * t * t
    else
      return 1 - 2 * (1 - t) * (1 - t)
    end
  end,
  
  -- Bounce effect
  bounce = function(t)
    if t < 0.36364 then
      return 7.5625 * t * t
    elseif t < 0.72727 then
      return 7.5625 * (t - 0.54545) * (t - 0.54545) + 0.75
    elseif t < 0.90909 then
      return 7.5625 * (t - 0.81818) * (t - 0.81818) + 0.9375
    else
      return 7.5625 * (t - 0.95455) * (t - 0.95455) + 0.984375
    end
  end,
  
  -- Elastic effect
  elastic = function(t)
    if t == 0 or t == 1 then
      return t
    else
      return -(2^(10 * (t - 1))) * math.sin((t - 1.1) * 5 * math.pi)
    end
  end
}

-- Color interpolation
animations.interpolate_color = function(start_color, end_color, progress)
  -- Extract RGBA components
  local start_a = (start_color >> 24) & 0xFF
  local start_r = (start_color >> 16) & 0xFF
  local start_g = (start_color >> 8) & 0xFF
  local start_b = start_color & 0xFF
  
  local end_a = (end_color >> 24) & 0xFF
  local end_r = (end_color >> 16) & 0xFF
  local end_g = (end_color >> 8) & 0xFF
  local end_b = end_color & 0xFF
  
  -- Interpolate each component
  local new_a = math.floor(start_a + (end_a - start_a) * progress)
  local new_r = math.floor(start_r + (end_r - start_r) * progress)
  local new_g = math.floor(start_g + (end_g - start_g) * progress)
  local new_b = math.floor(start_b + (end_b - start_b) * progress)
  
  -- Combine back to single color value
  return (new_a << 24) | (new_r << 16) | (new_g << 8) | new_b
end

-- Number interpolation
animations.interpolate_number = function(start_num, end_num, progress)
  return start_num + (end_num - start_num) * progress
end

-- Animate widget property over time
animations.animate_property = function(widget, property, start_value, end_value, duration, easing_func, callback)
  local start_time = os.clock()
  local easing = easing_func or animations.easing.ease_out
  
  -- Create animation timer
  local function update_animation()
    local current_time = os.clock()
    local elapsed = current_time - start_time
    local progress = math.min(elapsed / duration, 1.0)
    
    -- Apply easing
    local eased_progress = easing(progress)
    
    -- Interpolate value based on type
    local current_value
    if type(start_value) == "number" then
      if start_value > 0x1000000 then -- Assume it's a color if it's a large number
        current_value = animations.interpolate_color(start_value, end_value, eased_progress)
      else
        current_value = animations.interpolate_number(start_value, end_value, eased_progress)
      end
    else
      current_value = end_value -- For non-numeric values, just use end value
    end
    
    -- Update widget property
    local update_table = {}
    update_table[property] = current_value
    widget:set(update_table)
    
    -- Continue animation or complete
    if progress < 1.0 then
      -- Schedule next frame (approximately 60 FPS)
      sbar.exec("sleep 0.016 && echo 'continue'", function()
        update_animation()
      end)
    else
      -- Animation complete
      if callback then
        callback()
      end
    end
  end
  
  -- Start animation
  update_animation()
end

-- Smooth color transition for widget
animations.color_transition = function(widget, property_path, start_color, end_color, duration, easing_func, callback)
  local start_time = os.clock()
  local easing = easing_func or animations.easing.ease_out
  
  local function update_color()
    local current_time = os.clock()
    local elapsed = current_time - start_time
    local progress = math.min(elapsed / duration, 1.0)
    
    local eased_progress = easing(progress)
    local current_color = animations.interpolate_color(start_color, end_color, eased_progress)
    
    -- Build nested property update
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
      -- Handle deeper nesting if needed
      update_table[keys[1]] = { [keys[2]] = current_color }
    end
    
    widget:set(update_table)
    
    if progress < 1.0 then
      sbar.exec("sleep 0.016 && echo 'continue'", function()
        update_color()
      end)
    else
      if callback then
        callback()
      end
    end
  end
  
  update_color()
end

-- Fade in animation
animations.fade_in = function(widget, duration, easing_func, callback)
  local duration = duration or 0.3
  local easing = easing_func or animations.easing.ease_out
  
  -- Start from transparent
  widget:set({ background = { color = colors.transparent } })
  
  animations.color_transition(
    widget, 
    "background.color", 
    colors.transparent, 
    colors.bg1, 
    duration, 
    easing, 
    callback
  )
end

-- Fade out animation
animations.fade_out = function(widget, duration, easing_func, callback)
  local duration = duration or 0.3
  local easing = easing_func or animations.easing.ease_in
  
  animations.color_transition(
    widget, 
    "background.color", 
    colors.bg1, 
    colors.transparent, 
    duration, 
    easing, 
    callback
  )
end

-- Pulse animation (for notifications)
animations.pulse = function(widget, color1, color2, duration, cycles, callback)
  local duration = duration or 0.5
  local cycles = cycles or 3
  local current_cycle = 0
  
  local function pulse_cycle()
    current_cycle = current_cycle + 1
    
    -- Pulse to color2
    animations.color_transition(widget, "icon.color", color1, color2, duration / 2, animations.easing.ease_in_out, function()
      -- Pulse back to color1
      animations.color_transition(widget, "icon.color", color2, color1, duration / 2, animations.easing.ease_in_out, function()
        if current_cycle < cycles then
          pulse_cycle()
        else
          if callback then
            callback()
          end
        end
      end)
    end)
  end
  
  pulse_cycle()
end

-- Slide in animation (for popups)
animations.slide_in = function(widget, direction, distance, duration, easing_func, callback)
  local direction = direction or "up"
  local distance = distance or 20
  local duration = duration or 0.4
  local easing = easing_func or animations.easing.ease_out
  
  -- Set initial position
  local initial_offset = {
    up = { y_offset = distance },
    down = { y_offset = -distance },
    left = { x_offset = distance },
    right = { x_offset = -distance }
  }
  
  widget:set(initial_offset[direction])
  
  -- Animate to final position
  local final_offset = {
    up = { y_offset = 0 },
    down = { y_offset = 0 },
    left = { x_offset = 0 },
    right = { x_offset = 0 }
  }
  
  animations.animate_property(
    widget,
    direction == "up" or direction == "down" and "y_offset" or "x_offset",
    direction == "up" and distance or direction == "down" and -distance or 
    direction == "left" and distance or -distance,
    0,
    duration,
    easing,
    callback
  )
end

-- Scale animation
animations.scale = function(widget, start_scale, end_scale, duration, easing_func, callback)
  -- Note: SketchyBar doesn't directly support scaling, so we simulate with size changes
  local duration = duration or 0.3
  local easing = easing_func or animations.easing.ease_out
  
  -- This is a conceptual implementation - actual scaling would need width/height changes
  animations.animate_property(
    widget,
    "width",
    start_scale * 100, -- Assuming base width of 100
    end_scale * 100,
    duration,
    easing,
    callback
  )
end

-- Hover effect helper
animations.hover_effect = function(widget, hover_color, normal_color)
  return {
    enter = function()
      animations.color_transition(
        widget,
        "background.color",
        normal_color or colors.transparent,
        hover_color or colors.with_alpha(colors.bg2, 0.8),
        0.2,
        animations.easing.ease_out
      )
    end,
    
    exit = function()
      animations.color_transition(
        widget,
        "background.color",
        hover_color or colors.with_alpha(colors.bg2, 0.8),
        normal_color or colors.transparent,
        0.3,
        animations.easing.ease_out
      )
    end
  }
end

-- Loading animation (spinning or pulsing)
animations.loading = function(widget, style, speed, callback)
  local style = style or "pulse"
  local speed = speed or 1.0
  local is_loading = true
  
  local stop_loading = function()
    is_loading = false
    if callback then
      callback()
    end
  end
  
  if style == "pulse" then
    local function pulse_loop()
      if not is_loading then return end
      
      animations.color_transition(
        widget,
        "icon.color",
        colors.grey,
        colors.blue,
        0.5 / speed,
        animations.easing.ease_in_out,
        function()
          if not is_loading then return end
          animations.color_transition(
            widget,
            "icon.color",
            colors.blue,
            colors.grey,
            0.5 / speed,
            animations.easing.ease_in_out,
            pulse_loop
          )
        end
      )
    end
    
    pulse_loop()
  end
  
  return stop_loading
end

-- Chain multiple animations
animations.chain = function(animation_list)
  local current_index = 1
  
  local function run_next()
    if current_index <= #animation_list then
      local anim = animation_list[current_index]
      current_index = current_index + 1
      
      anim.func(table.unpack(anim.args or {}), run_next)
    end
  end
  
  run_next()
end

-- Parallel animations
animations.parallel = function(animation_list, callback)
  local completed_count = 0
  local total_animations = #animation_list
  
  local function animation_complete()
    completed_count = completed_count + 1
    if completed_count == total_animations and callback then
      callback()
    end
  end
  
  for _, anim in ipairs(animation_list) do
    anim.func(table.unpack(anim.args or {}), animation_complete)
  end
end

return animations