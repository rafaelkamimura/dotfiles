-- External link opening functionality
-- This plugin provides gx functionality to open URLs, GitHub links, and more
-- without needing netrw

return {
  {
    "chrishrb/gx.nvim",
    keys = { 
      { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open link under cursor" },
      { "<leader>ox", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open link under cursor" },
      { "<S-LeftMouse>", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Open link with Shift+click" },
    },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx to avoid conflicts
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gx").setup({
        open_browser_app = "open", -- macOS default browser opener
        open_browser_args = { "--background" }, -- open in background to keep Neovim focused
        select_prompt = true, -- show prompt when multiple handlers match
        handlers = {
          plugin = true, -- open plugin links (e.g., lazy.nvim specs, Packer, etc.)
          github = true, -- open GitHub issues, PRs, and repositories
          brewfile = true, -- open Homebrew formulae and casks
          package_json = true, -- open npm package pages
          search = true, -- search the web if no other handler matches
          go = true, -- open pkg.go.dev from Go import statements
          rust = {
            name = "rust", -- custom handler for Rust crates
            filetype = { "toml" },
            filename = "Cargo.toml",
            handle = function(mode, line, _)
              local crate = require("gx.helper").find(line, mode, "(%w+)%s-=%s")
              if crate then
                return "https://crates.io/crates/" .. crate
              end
            end,
          },
        },
        handler_options = {
          search_engine = "google", -- default search engine for web searches
          select_for_search = false, -- prefer link over word search when both match
          git_remotes = { "upstream", "origin" }, -- git remotes in priority order
        },
      })
    end,
  },
}