-- ~/.config/nvim/lua/plugins/lsp/servers.lua

local M = {}

M.setup = function()
  -- Import necessary modules
  local lspconfig = require 'lspconfig'
  local cmp_nvim_lsp = require 'cmp_nvim_lsp'

  -- Default capabilities for LSP servers with cmp_nvim_lsp integration
  local default_capabilities = vim.lsp.protocol.make_client_capabilities()
  default_capabilities = vim.tbl_deep_extend('force', default_capabilities, cmp_nvim_lsp.default_capabilities())

  -- Function to determine the Python executable based on the active virtual environment
  local function get_python_path()
    if vim.env.VIRTUAL_ENV then
      -- For Unix-based systems
      return vim.env.VIRTUAL_ENV .. '/bin/python'
      -- For Windows systems, uncomment the following line and comment out the Unix line above
      -- return vim.env.VIRTUAL_ENV .. '\\Scripts\\python.exe'
    else
      -- Fallback to system Python; adjust the path if necessary
      return '/usr/bin/python'
    end
  end

  -- Define LSP servers and their specific configurations
  M.servers = {
    -- Bash Language Server
    bashls = {
      settings = {},
      capabilities = default_capabilities,
    },

    -- JSON Language Server
    jsonls = {
      settings = {},
      capabilities = default_capabilities,
    },

    -- Markdown Language Server
    marksman = {
      settings = {},
      capabilities = default_capabilities,
    },

    -- XML Language Server
    lemminx = {
      settings = {},
      capabilities = default_capabilities,
    },

    -- YAML Language Server
    yamlls = {
      settings = {},
      capabilities = default_capabilities,
    },

    -- Lua Language Server
    lua_ls = {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
      capabilities = default_capabilities,
    },

    -- Python Language Server (pylsp)
    pylsp = {
      -- Pass environment variables to pylsp
      cmd_env = {
        VIRTUAL_ENV = vim.env.VIRTUAL_ENV or '',
        PATH = vim.env.PATH,
        PYTHONPATH = vim.env.PYTHONPATH or '',
      },
      settings = {
        pylsp = {
          configurationSources = { 'pylsp_mypy' }, -- Use pylsp_mypy for diagnostics
          plugins = {
            -- MyPy Plugin Configuration
            pylsp_mypy = {
              enabled = true,
              live_mode = false, -- Run MyPy on save
              strict = true, -- Enable strict type checking
              report_progress = true, -- Show progress in status line
              overrides = { '--python-executable', get_python_path(), true }, -- Specify Python executable
            },
            -- Rope (Refactoring) Plugin
            pylsp_rope = {
              enabled = true,
            },
            -- Black (Formatter) Plugin
            pylsp_black = {
              enabled = true,
            },
            -- Isort (Import Sorting) Plugin
            pylsp_isort = {
              enabled = true,
            },
            -- Disable Pyflakes Linter
            pylsp_pyflakes = {
              enabled = false,
            },
            -- Disable McCabe Complexity Checker
            pylsp_mccabe = {
              enabled = false,
            },
            -- Disable Pylint Linter
            pylsp_pylint = {
              enabled = false,
            },
            -- Disable Hover in pylsp to delegate to pyright
            pylsp_hover = {
              enabled = false,
            },
            -- Jedi Completion Plugin
            jedi_completion = {
              enabled = true,
              fuzzy = true, -- Enable fuzzy matching for better suggestions
            },
            -- Disable Jedi Hover Plugin to prevent conflicts with pyright
            jedi_hover = {
              enabled = false,
            },
            -- Specify Jedi's Python environment
            jedi = {
              environment = get_python_path(),
            },
          },
        },
      },
      capabilities = default_capabilities,
      flags = {
        debounce_text_changes = 200, -- Adjust debounce time (milliseconds)
      },
    },

    -- TOML Language Server
    taplo = {
      settings = {},
      capabilities = default_capabilities,
    },

    -- Pyright Language Server (for hover only)
    pyright = {
      settings = {
        python = {
          pythonPath = get_python_path(),
          analysis = {
            typeCheckingMode = 'off', -- Disable type checking to prevent diagnostics
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
      capabilities = {
        textDocument = {
          hover = default_capabilities.textDocument.hover, -- Enable hover
        },
      },
      flags = {
        debounce_text_changes = 200, -- Match pylsp's debounce time
      },
      -- on_attach function to disable all capabilities except hover
      on_attach = function(client, bufnr)
        -- Disable all capabilities except hover to ensure pyright only handles hover
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        client.server_capabilities.completionProvider = false
        client.server_capabilities.renameProvider = false
        client.server_capabilities.codeActionProvider = false
        client.server_capabilities.referencesProvider = false
        client.server_capabilities.signatureHelpProvider = false
        client.server_capabilities.documentSymbolProvider = false
        client.server_capabilities.definitionProvider = false
        client.server_capabilities.typeDefinitionProvider = false
        client.server_capabilities.implementationProvider = false
        client.server_capabilities.documentHighlightProvider = false
        -- Hover remains enabled
      end,
    },
  }

  -- Set up each server using lspconfig
  for server_name, server in pairs(M.servers) do
    lspconfig[server_name].setup(server)
  end
end

return M
