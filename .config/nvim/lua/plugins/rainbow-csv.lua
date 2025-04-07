return {
  'cameron-wags/rainbow_csv.nvim',
  config = function()
    -- Disable hovering column information
    vim.g.disable_rainbow_hover = 1

    -- Or alternatively set a debounce time if you prefer
    -- vim.g.rainbow_hover_debounce_ms = 300

    require('rainbow_csv').setup()
  end,
  ft = {
    'csv',
    'tsv',
    'csv_semicolon',
    'csv_whitespace',
    'csv_pipe',
    'rfc_csv',
    'rfc_semicolon',
  },
  cmd = {
    'RainbowDelim',
    'RainbowDelimSimple',
    'RainbowDelimQuoted',
    'RainbowMultiDelim',
  },
}
