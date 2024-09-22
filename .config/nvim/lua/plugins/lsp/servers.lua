-- servers.lua

local M = {}

M.setup = function()
  -- Create default capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  -- Function to get Python executable from virtual environment or default
  local function get_python_path()
    -- Use activated virtualenv
    if vim.env.VIRTUAL_ENV then
      return vim.env.VIRTUAL_ENV .. '/bin/python'
    else
      -- Fallback to system Python (adjust as necessary)
      return '/usr/bin/python'
    end
  end

  -- Define LSP servers and their settings
  M.servers = {
    bashls = {
      -- Add any specific settings for bashls here
    },
    jsonls = {
      -- Add any specific settings for jsonls here
    },
    marksman = {
      -- Add any specific settings for marksman here
    },
    lemminx = {
      -- Add any specific settings for lemminx here
    },
    yamlls = {
      -- Add any specific settings for yamlls here
    },
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
    },
    pylsp = {
      cmd_env = {
        VIRTUAL_ENV = vim.env.VIRTUAL_ENV or '',
        PATH = vim.env.PATH,
        PYTHONPATH = vim.env.PYTHONPATH or '',
      },
      settings = {
        pylsp = {
          configurationSources = { 'pylsp_mypy' },
          plugins = {
            pylsp_mypy = {
              enabled = true,
              live_mode = false,
              strict = true,
              report_progress = true,
              overrides = { '--python-executable', get_python_path(), true },
            },
            pylsp_rope = {
              enabled = true,
            },
            pylsp_black = {
              enabled = true,
            },
            pylsp_isort = {
              enabled = true,
            },
            pylsp_pyflakes = {
              enabled = false,
            },
            pylsp_mccabe = {
              enabled = false,
            },
            pylsp_pylint = {
              enabled = false,
            },
            pylsp_hover = {
              enabled = true,
            },
            jedi_completion = {
              enabled = true,
              fuzzy = true,
            },
            jedi = {
              environment = get_python_path(),
            },
          },
        },
      },
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 200,
      },
    },
    taplo = {
      -- Add any specific settings for taplo here
    },
  }

  -- Set up each server using lspconfig
  for server_name, server in pairs(M.servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    require('lspconfig')[server_name].setup(server)
  end
end

return M
