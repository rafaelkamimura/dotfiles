-- Unified TreeSitter configuration
-- This replaces scattered TreeSitter configurations across multiple files
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure all required parsers are installed
      opts.ensure_installed = opts.ensure_installed or {}
      
      -- Add all the parsers that were scattered across different files
      local parsers = {
        -- Base parsers
        "bash", "html", "javascript", "json", "lua", "markdown", "markdown_inline", "python",
        "query", "regex", "tsx", "typescript", "vim", "yaml",
        
        -- Language-specific parsers
        "rust", "ron", "toml",  -- Rust
        "go", "gomod", "gowork", "gosum", "gotmpl",  -- Go (including missing gotmpl)
        "c", "cpp", "cmake", "make", "ninja", "cuda", "proto",  -- C++
        "vue", "astro", "svelte", "graphql", "styled", "css", "scss",  -- Frameworks (sass parser doesn't exist)
        "jsdoc", "json5", "jsonc",  -- TypeScript/JavaScript
        
        -- Missing parsers that were reported
        "sql", "comment",
      }
      
      -- Extend the existing list with new parsers
      for _, parser in ipairs(parsers) do
        if not vim.tbl_contains(opts.ensure_installed, parser) then
          table.insert(opts.ensure_installed, parser)
        end
      end
      
      -- Enhanced syntax highlighting configuration
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true
      opts.highlight.additional_vim_regex_highlighting = false
      
      -- Performance optimization: disable treesitter highlighting for very large files
      opts.highlight.disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end
      
      -- Enable incremental selection
      opts.incremental_selection = opts.incremental_selection or {}
      opts.incremental_selection.enable = true
      opts.incremental_selection.keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      }
      
      -- Enable text objects
      opts.textobjects = opts.textobjects or {}
      opts.textobjects.select = opts.textobjects.select or {}
      opts.textobjects.select.enable = true
      opts.textobjects.select.lookahead = true
      
      return opts
    end,
    config = function(_, opts)
      -- Set up file type associations (from rust-formatting.lua)
      vim.filetype.add({
        extension = {
          rs = "rust",
          toml = "toml",
        },
        filename = {
          ["Cargo.toml"] = "toml",
          ["Cargo.lock"] = "toml",
          ["rust-toolchain"] = "toml",
          ["rust-toolchain.toml"] = "toml",
        },
      })
      
      -- Apply the configuration
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}