local M = {}

-- Set up LSP keymaps via LspAttach autocmd
-- This is called once during config loading, not as a lazy.nvim plugin
local function setup_lsp_keymaps()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Use functions to defer telescope require until the keymap is invoked
      -- This ensures telescope is loaded by lazy.nvim when needed
      map('gd', function()
        require('telescope.builtin').lsp_definitions()
      end, '[G]oto [D]efinition')
      map('gr', function()
        require('telescope.builtin').lsp_references()
      end, '[G]oto [R]eferences')
      map('gj', function()
        require('telescope.builtin').lsp_references()
      end, '[G]oto [R]eferences (alt)')
      map('gI', function()
        require('telescope.builtin').lsp_implementations()
      end, '[G]oto [I]mplementation')
      map('<leader>D', function()
        require('telescope.builtin').lsp_type_definitions()
      end, 'Type [D]efinition')
      map('<leader>ws', function()
        require('telescope.builtin').lsp_dynamic_workspace_symbols()
      end, '[W]orkspace [S]ymbols')
      map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Diagnostic mappings
      map('d]', vim.diagnostic.goto_next, 'Go to next diagnostic')
      map('d[', vim.diagnostic.goto_prev, 'Go to prev diagnostic')
      map('d/', vim.diagnostic.setloclist, 'Send diagnostics to loc list')
      map('de', vim.diagnostic.open_float, 'Show diagnostic in floating window')

      -- Hover mapping
      map('K', vim.lsp.buf.hover, 'Hover Documentation')

      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        require('plugins.lsp-and-tools.highlight').setup(event)
      end
      if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end
    end,
  })
end

M.setup = function()
  setup_lsp_keymaps()
  -- Return nil explicitly - this function is called for side effects only
  return nil
end

return M
