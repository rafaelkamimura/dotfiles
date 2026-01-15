return {
  -- Override blink.cmp configuration to include Copilot and Tab completion
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Interview mode: skip Copilot integration
      local is_interview = vim.env.NVIM_INTERVIEW

      if not is_interview then
        -- Add Copilot to the sources
        opts.sources = opts.sources or {}
        opts.sources.default = opts.sources.default or {}
        table.insert(opts.sources.default, "copilot")

        -- Configure Copilot source
        opts.sources.providers = opts.sources.providers or {}
        opts.sources.providers.copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100, -- Higher priority than other sources
          async = true,
        }
      end

      -- Configure Tab key to accept completions
      opts.keymap = opts.keymap or {}
      opts.keymap.preset = "default"
      opts.keymap["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        "snippet_forward",
        "fallback"
      }
      opts.keymap["<S-Tab>"] = { "snippet_backward", "fallback" }

      -- Ensure Enter also works for accepting completions
      opts.keymap["<CR>"] = { "accept", "fallback" }

      -- Configure completion behavior
      opts.completion = opts.completion or {}
      opts.completion.accept = opts.completion.accept or {}
      opts.completion.accept.auto_brackets = {
        enabled = true,
      }
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.menu.auto_show = true

      return opts
    end,
  },
}
