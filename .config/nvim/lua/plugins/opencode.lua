-- OpenCode.nvim - AI assistant integration
-- https://github.com/NickvanDyke/opencode.nvim
if vim.env.NVIM_INTERVIEW then
  return {}
end

return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      {
        "folke/snacks.nvim",
        opts = {
          input = {},
          picker = {},
          terminal = {},
        },
      },
    },
    keys = {
      -- Toggle opencode interface
      { "<C-.>", function() require("opencode").toggle() end, desc = "Toggle OpenCode", mode = { "n", "v" } },
      -- Quick prompt input
      { "<leader>aa", function() require("opencode").prompt() end, desc = "OpenCode prompt", mode = "n" },
      { "<leader>aa", function() require("opencode").prompt() end, desc = "OpenCode prompt with selection", mode = "v" },
      -- Toggle panel
      { "<leader>ap", function() require("opencode").toggle() end, desc = "Toggle OpenCode panel", mode = "n" },
    },
    config = function()
      require("opencode").setup({
        -- Provider: auto-detect or specify
        -- Options: "neovim", "snacks", "kitty", "wezterm", "tmux"
        provider = "snacks",
      })
      -- Enable autoread for file changes from opencode
      vim.o.autoread = true
    end,
  },
}
