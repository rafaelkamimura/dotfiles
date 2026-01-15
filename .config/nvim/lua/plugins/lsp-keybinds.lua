-- Proper LSP Navigation Keybinds
-- Fixes jump to definition and other LSP navigation
return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Set up proper LSP keybinds that work consistently
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      
      -- Override/add the essential navigation keybinds
      vim.list_extend(keys, {
        -- Core navigation (standard vim-style)
        { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
        { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
        { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation", has = "implementation" },
        { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
        { "gt", vim.lsp.buf.type_definition, desc = "Goto Type Definition", has = "typeDefinition" },
        
        -- Alternative leader-based navigation
        { "<leader>gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
        { "<leader>gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
        { "<leader>gi", vim.lsp.buf.implementation, desc = "Goto Implementation", has = "implementation" },
        { "<leader>gr", vim.lsp.buf.references, desc = "References", nowait = true },
        { "<leader>gt", vim.lsp.buf.type_definition, desc = "Goto Type Definition", has = "typeDefinition" },
        
        -- Documentation and hover
        { "K", vim.lsp.buf.hover, desc = "Hover" },
        { "gK", vim.lsp.buf.signature_help, desc = "Signature Help", has = "signatureHelp" },
        
        -- Code actions and diagnostics
        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
        { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
        { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
        
        -- Diagnostics navigation
        { "[d", vim.diagnostic.goto_prev, desc = "Previous Diagnostic" },
        { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
        { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
        { "<leader>cq", vim.diagnostic.setloclist, desc = "Quickfix Diagnostics" },

        -- Call hierarchy navigation
        { "<leader>ci", vim.lsp.buf.incoming_calls, desc = "Incoming Calls", has = "callHierarchy/incomingCalls" },
        { "<leader>co", vim.lsp.buf.outgoing_calls, desc = "Outgoing Calls", has = "callHierarchy/outgoingCalls" },
      })
    end,
    opts = {
      -- Ensure diagnostics are properly configured
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      },
      -- Ensure inlay hints work properly
      inlay_hints = {
        enabled = true,
        exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
      },
      -- Ensure codelens work
      codelens = {
        enabled = true,
      },
      -- Document highlighting
      document_highlight = {
        enabled = true,
      },
      -- Configure capabilities properly
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
    },
  },

  -- Ensure LSP servers are properly configured with the right capabilities
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Make sure all servers have the right capabilities for navigation
      opts.servers = opts.servers or {}
      
      -- Ensure common navigation capabilities are enabled
      local servers = { "pyright", "gopls", "vtsls", "clangd", "rust_analyzer" }
      for _, server in ipairs(servers) do
        if opts.servers[server] then
          opts.servers[server].capabilities = opts.servers[server].capabilities or {}
          -- Ensure definition/declaration/implementation capabilities
          local caps = opts.servers[server].capabilities
          caps.textDocument = caps.textDocument or {}
          caps.textDocument.definition = { dynamicRegistration = true, linkSupport = true }
          caps.textDocument.declaration = { dynamicRegistration = true, linkSupport = true }
          caps.textDocument.implementation = { dynamicRegistration = true, linkSupport = true }
          caps.textDocument.typeDefinition = { dynamicRegistration = true, linkSupport = true }
          caps.textDocument.references = { dynamicRegistration = true }
        end
      end
      
      return opts
    end,
  },

  -- Add telescope integration for better LSP navigation
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Peek Definition (view in Telescope without jumping)
      {
        "<leader>vd",
        function()
          require("telescope.builtin").lsp_definitions({ jump_type = "never" })
        end,
        desc = "View/Peek Definition",
      },
      -- Enhanced LSP navigation with telescope
      { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
      { "<leader>sS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
      { "<leader>sr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
      { "<leader>si", "<cmd>Telescope lsp_implementations<cr>", desc = "Implementations" },
      { "<leader>st", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type Definitions" },
    },
  },
}