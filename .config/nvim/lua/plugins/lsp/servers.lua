-- servers.lua

local M = {}

M.setup = function()
  -- Create default capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  -- Define LSP servers and their settings
  M.servers = {
    bashls = {
      -- You can add specific settings for bashls here if needed
    },
    jsonls = {
      -- You can add specific settings for jsonls here if needed
    },
    marksman = {
      -- You can add specific settings for marksman here if needed
    },
    lemminx = {
      -- You can add specific settings for lemminx here if needed
    },
    yamlls = {
      -- You can add specific settings for yamlls here if needed
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
      settings = {
        pylsp = {
          configurationSources = { 'pylsp_mypy' }, -- Use pylsp_mypy for diagnostics
          plugins = {
            pylsp_mypy = {
              enabled = true,
              live_mode = false, -- Set to true for real-time checking (may affect performance)
              strict = true,
              report_progress = true, -- Optional: shows progress in the status line
            },
            pylsp_rope = {
              enabled = true,
            },
            pylsp_black = {
              enabled = true,
            },
            pylsp_isort = { -- Corrected from 'pyls_isort' to 'pylsp_isort'
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
          },
        },
      },
      capabilities = capabilities,
    },
    taplo = {
      -- You can add specific settings for taplo here if needed
    },
  }

  -- Set up each server using lspconfig
  for server_name, server in pairs(M.servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    require('lspconfig')[server_name].setup(server)
  end
end

return M
