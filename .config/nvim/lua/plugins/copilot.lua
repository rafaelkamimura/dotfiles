-- Interview mode: disable all AI assistants
if vim.env.NVIM_INTERVIEW then
  return {}
end

return {
  -- GitHub Copilot main plugin
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",      -- Alt+l to accept suggestion
          accept_word = "<M-w>", -- Alt+w to accept word
          accept_line = "<M-j>", -- Alt+j to accept line
          next = "<M-]>",        -- Alt+] for next suggestion
          prev = "<M-[>",        -- Alt+[ for previous suggestion
          dismiss = "<C-]>",     -- Ctrl+] to dismiss
        },
      },
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>", -- Alt+Enter to open panel
        },
        layout = {
          position = "bottom", -- | top | left | right
          ratio = 0.4,
        },
      },
      filetypes = {
        -- Enable for programming languages
        python = true,
        javascript = true,
        typescript = true,
        lua = true,
        go = true,
        rust = true,
        java = true,
        c = true,
        cpp = true,
        -- Disable for non-code files
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
      copilot_node_command = "node", -- Node.js version must be > 18.x
      server_opts_overrides = {},
    },
  },

  -- Copilot Chat for AI-powered conversations
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = {
      "CopilotChat",
      "CopilotChatOpen",
      "CopilotChatClose",
      "CopilotChatToggle",
      "CopilotChatStop",
      "CopilotChatReset",
      "CopilotChatExplain",
      "CopilotChatReview",
      "CopilotChatFix",
      "CopilotChatOptimize",
      "CopilotChatDocs",
      "CopilotChatTests",
    },
    opts = {
      debug = false,
    },
  },

  -- Integration with blink.cmp completion engine
  {
    "giuxtaposition/blink-cmp-copilot",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
  },
}