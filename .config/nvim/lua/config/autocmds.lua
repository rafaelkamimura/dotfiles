-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Python-specific autocmds
local python_group = vim.api.nvim_create_augroup("PythonConfig", { clear = true })

-- Auto-format Python files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = python_group,
  pattern = "*.py",
  callback = function()
    -- Use LazyVim's format function which respects conform.nvim and LSP formatting
    LazyVim.format({ force = true })
  end,
  desc = "Auto-format Python files on save",
})

-- Set Python-specific options
vim.api.nvim_create_autocmd("FileType", {
  group = python_group,
  pattern = "python",
  callback = function()
    -- Set line length to 120 for Python files
    vim.opt_local.textwidth = 120
    vim.opt_local.colorcolumn = "120"
    
    -- Enable spell checking for comments and strings
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    
    -- Python-specific indentation (though LazyVim should handle this)
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
  desc = "Set Python-specific options",
})
