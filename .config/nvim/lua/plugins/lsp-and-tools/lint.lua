-- lint.lua
local language_utils = require 'plugins.lsp-and-tools.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = configs.linters

      -- Apply linter options
      for linter_name, options in pairs(configs.linter_options) do
        if lint.linters[linter_name] then
          lint.linters[linter_name].args = options.args or lint.linters[linter_name].args
        end
      end

      -- Create an autocommand group
      local lint_augroup = vim.api.nvim_create_augroup('Linting', { clear = true })

      -- Set up autocommands to trigger linting
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  }
end

return M
