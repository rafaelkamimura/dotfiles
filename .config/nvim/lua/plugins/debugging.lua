-- Comprehensive Debugging Configuration for JavaScript/TypeScript
-- Supports Node.js, React, Vue, Next.js with nvim-dap
return {
  -- Debug Adapter Protocol (DAP)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI enhancements for debugging
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {
          controls = {
            element = "repl",
            enabled = true,
            icons = {
              disconnect = "",
              pause = "",
              play = "",
              run_last = "",
              step_back = "",
              step_into = "",
              step_out = "",
              step_over = "",
              terminate = "",
            },
          },
          element_mappings = {},
          expand_lines = true,
          floating = {
            border = "single",
            mappings = { close = { "q", "<Esc>" } },
          },
          force_buffers = true,
          icons = {
            collapsed = "",
            current_frame = "",
            expanded = "",
          },
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.25 },
                { id = "breakpoints", size = 0.25 },
                { id = "stacks", size = 0.25 },
                { id = "watches", size = 0.25 },
              },
              position = "left",
              size = 40,
            },
            {
              elements = {
                { id = "repl", size = 0.5 },
                { id = "console", size = 0.5 },
              },
              position = "bottom",
              size = 10,
            },
          },
          mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            repl = "r",
            toggle = "t",
          },
          render = {
            indent = 1,
            max_value_lines = 100,
          },
        },
        config = function(_, opts)
          local dap = require("dap")
          local dapui = require("dapui")
          dapui.setup(opts)
          
          -- Auto-open/close DAP UI
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({})
          end
        end,
      },
      
      -- Virtual text during debugging
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = false,
          show_stop_reason = true,
          commented = false,
          only_first_definition = true,
          all_references = false,
          clear_on_continue = false,
          display_callback = function(variable, buf, stackframe, node, options)
            -- Customize how variables are displayed
            if options.virt_text_pos == "inline" then
              return " = " .. variable.value
            else
              return variable.name .. " = " .. variable.value
            end
          end,
          virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
          all_frames = false,
          virt_lines = false,
          virt_text_win_col = nil,
        },
      },
    },
    
    config = function()
      local dap = require("dap")
      local mason_registry = require("mason-registry")
      
      -- Get the path to js-debug-adapter
      local js_debug_adapter_path = mason_registry.get_package("js-debug-adapter"):get_install_path()
      
      -- Configure the Node.js adapter
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            js_debug_adapter_path .. "/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
      
      -- Configure the Chrome adapter for client-side debugging
      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            js_debug_adapter_path .. "/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
      
      -- TypeScript and JavaScript configurations
      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = {
          -- Debug single Node.js files
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug Node.js with ts-node
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch with ts-node",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "node",
            runtimeArgs = {
              "--loader",
              "ts-node/esm",
            },
            sourceMaps = true,
            protocol = "inspector",
            skipFiles = { "<node_internals>/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug Node.js applications
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch Node.js Program",
            program = "${workspaceFolder}/src/index.js", -- Adjust path as needed
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Attach to running Node.js process
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Node.js",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            skipFiles = { "<node_internals>/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug npm scripts
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug npm start",
            runtimeExecutable = "npm",
            runtimeArgs = { "start" },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug Jest tests
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/.bin/jest",
              "--runInBand",
              "--no-coverage",
              "${file}",
            },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug Vitest tests
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Vitest Tests",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "test", "--", "--run", "${file}" },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
        }
      end
      
      -- TypeScript React configurations
      for _, language in ipairs({ "typescriptreact", "javascriptreact" }) do
        dap.configurations[language] = {
          -- Debug React applications in Chrome
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome for React",
            url = "http://localhost:3000", -- Adjust port as needed
            webRoot = "${workspaceFolder}/src",
            sourceMaps = true,
            protocol = "inspector",
            userDataDir = false,
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug Next.js applications
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Next.js",
            program = "${workspaceFolder}/node_modules/.bin/next",
            args = { "dev" },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          
          -- Debug Vite React applications
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome for Vite React",
            url = "http://localhost:5173", -- Vite default port
            webRoot = "${workspaceFolder}/src",
            sourceMaps = true,
            protocol = "inspector",
            userDataDir = false,
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
        }
      end
      
      -- Vue.js configurations
      dap.configurations.vue = {
        -- Debug Vue applications in Chrome
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome for Vue",
          url = "http://localhost:8080", -- Vue CLI default port
          webRoot = "${workspaceFolder}/src",
          sourceMaps = true,
          protocol = "inspector",
          userDataDir = false,
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
        },
        
        -- Debug Nuxt.js applications
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Nuxt.js",
          program = "${workspaceFolder}/node_modules/.bin/nuxt",
          args = { "dev" },
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
          resolveSourceMapLocations = {
            "${workspaceFolder}/**",
            "!**/node_modules/**",
          },
        },
      }
      
      -- Set breakpoint icons
      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "DapBreakpointRejected",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "",
        texthl = "DapLogPoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })
    end,
    
    keys = {
      -- Debug session controls
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Set Conditional Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue/Start Debugging",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dd",
        function()
          require("dap").disconnect()
        end,
        desc = "Disconnect Debugger",
      },
      {
        "<leader>dg",
        function()
          require("dap").session()
        end,
        desc = "Get Session",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").restart()
        end,
        desc = "Restart Session",
      },
      {
        "<leader>dS",
        function()
          require("dap").step_back()
        end,
        desc = "Step Back",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate Session",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Hover Variables",
      },
      {
        "<leader>dW",
        function()
          local widgets = require("dap.ui.widgets")
          widgets.centered_float(widgets.scopes)
        end,
        desc = "Show Scopes",
      },
      
      -- DAP UI controls
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Toggle Debug UI",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Evaluate Expression",
        mode = { "n", "v" },
      },
      
      -- Quick debug configurations
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last Debug Configuration",
      },
    },
  },

  -- Mason tool installer for debugging tools
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "js-debug-adapter",
        "chrome-debug-adapter",
        "firefox-debug-adapter",
      })
    end,
  },

  -- Overseer task templates for debugging
  {
    "stevearc/overseer.nvim",
    optional = true,
    opts = {
      task_list = {
        bindings = {
          ["<C-d>"] = "OpenFloat",
        },
      },
    },
  },
}