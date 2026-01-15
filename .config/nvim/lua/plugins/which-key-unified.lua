-- Unified Which-Key Configuration
-- Consolidates all which-key mappings to prevent conflicts
return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        -- Mode specifications
        { mode = { "n", "v" } },
        
        -- Core groups
        { "<leader>a", group = "ai/copilot" },
        { "<leader>c", group = "code" },
        { "<leader>q", group = "session/quit" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "goto/git" },
        { "<leader>s", group = "search/symbols" },
        { "<leader>t", group = "test" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/quickfix" },
        
        -- Code subgroups
        { "<leader>ca", group = "code action" },
        { "<leader>cf", group = "format" },
        { "<leader>ci", group = "import" },
        { "<leader>cr", group = "refactor" },
        
        -- Language-specific groups
        { "<leader>cm", group = "cmake" },
        { "<leader>ct", group = "typescript" },
        { "<leader>r", group = "rust" },
        
        -- Framework groups
        { "<leader>fr", group = "react" },
        { "<leader>fv", group = "vue" },
        { "<leader>fn", group = "next" },
        { "<leader>fa", group = "astro" },
        { "<leader>fs", group = "svelte" },
        
        -- Package management
        { "<leader>n", group = "npm/node" },
        { "<leader>p", group = "project" },
        { "<leader>pa", group = "package audit" },
        { "<leader>pi", group = "package install" },
        { "<leader>pr", group = "package run" },
        { "<leader>pu", group = "package update" },
        
        -- Cargo/Rust specific
        { "<leader>rc", group = "cargo" },
        { "<leader>rb", group = "build" },
        { "<leader>rt", group = "test" },
        { "<leader>rd", group = "doc" },
        { "<leader>rr", group = "run" },
      },
    },
  },
}