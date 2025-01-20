local language_utils = require 'plugins.lsp-and-tools.language_utils'
local M = {}

function M.setup(languages)
  local configs = language_utils.collect_configurations(languages)
  return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        'M',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      formatters_by_ft = configs.formatters,
      formatters = configs.formatters_options,
      format_on_save = function(bufnr)
        -- Define the list of filetypes to NOT format on save
        local no_format_on_save_filetypes = {
          'go',
          'ruby',
          'dockerfile',
          'cpp',
          'python',
          'bash',
          'sh',
          'typescript',
        }

        -- Get the filetype of the current buffer
        local filetype = vim.bo[bufnr].filetype

        -- Check if the current filetype should not be formatted on save
        if vim.tbl_contains(no_format_on_save_filetypes, filetype) then
          return false
        else
          return {
            timeout_ms = 5000,
            lsp_fallback = true,
          }
        end
      end,
    },
    config = function(_, opts)
      local conform = require 'conform'
      -- Register custom formatter configurations
      for formatter_name, formatter_opts in pairs(opts.formatters) do
        conform.formatters[formatter_name] = formatter_opts
      end
      conform.setup(opts)
    end,
  }
end

return M
