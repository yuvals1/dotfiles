-- TODO: integrate servers and mason setup to work togheter, right there is duplicated of lsp that are defined
-- TODO: understand the meaning of  vim.lsp.protocol.make_client_capabilities() as can be shown in https://www.reddit.com/r/neovim/comments/1f3vl5h/how_to_set_up_python_with_static_type_checking/

local M = {}

M.setup = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

  M.servers = {
    bashls = {
      settings = {
        filetypes = { 'sh', 'zsh' },
      },
    },
    jsonls = {},
    marksman = {},
    lemminx = {},
    yamlls = {},
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
    jedi_language_server = {
      init_options = {
        completion = {
          disableSnippets = false,
          resolveEagerly = false,
          ignorePatterns = {},
        },
        diagnostics = {
          enable = true,
          didOpen = true,
          didChange = true,
          didSave = true,
        },
        hover = {
          enable = true,
        },
        markupKindPreferred = 'markdown',
      },
    },
  }

  for server_name, server in pairs(M.servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    require('lspconfig')[server_name].setup(server)
  end
end

return M
