local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
  height = 32,
  color = colors.bar.bg,
  padding_right = 6,
  padding_left = 6,
  margin = 2,
  y_offset = 2,
  corner_radius = 8,
  blur_radius = 25,
  shadow = true,
  position = "top",
  sticky = true,
  topmost = true,
})
