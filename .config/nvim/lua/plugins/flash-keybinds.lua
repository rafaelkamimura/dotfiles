-- Flash.nvim - Enhanced Navigation & Motion
-- Provides quick jumping and enhanced f/t motions
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- Jump mode (search and jump to any word)
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      -- Treesitter selection (incrementally select treesitter nodes)
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- Remote flash (jump in operator-pending mode)
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- Treesitter search (search within treesitter nodes)
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- Toggle flash in search mode
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
