-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Mouse support configuration
vim.opt.mouse = "a" -- Enable mouse support in all modes
vim.opt.mousemodel = "extend" -- Enable extend selection with mouse

-- Enable mouse integration for better terminal compatibility
vim.opt.mousetime = 500 -- Time for double-click detection

-- =============================================================================
-- Clipboard Configuration (macOS pbcopy/pbpaste - most reliable through tmux)
-- =============================================================================

-- Use pbcopy/pbpaste on macOS (works reliably through tmux)
if vim.fn.has('mac') == 1 then
  vim.g.clipboard = {
    name = 'macOS-clipboard',
    copy = {
      ['+'] = 'pbcopy',
      ['*'] = 'pbcopy',
    },
    paste = {
      ['+'] = 'pbpaste',
      ['*'] = 'pbpaste',
    },
    cache_enabled = 0,
  }
end

-- Force clipboard=unnamedplus after LazyVim's deferred loading
-- LazyVim defers clipboard for performance, this ensures our setting sticks
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.opt.clipboard = "unnamedplus"
  end,
})
