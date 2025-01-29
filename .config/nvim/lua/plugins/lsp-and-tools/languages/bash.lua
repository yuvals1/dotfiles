return {
  mason = {
    'bash-language-server',
    'shellcheck',
    'shfmt',
  },

  lsp = {
    bashls = {
      filetypes = { 'sh', 'bash' },
    },
  },

  formatters = {
    sh = { 'shfmt' },
    bash = { 'shfmt' },
  },

  formatter_options = {
    ['shfmt'] = {
      command = vim.fn.stdpath 'data' .. '/mason/bin/shfmt', -- Use Mason's shfmt
      args = {
        '--filename',
        '$FILENAME', -- Needed for proper file detection
        '-bn', -- Binary ops may start a line
        '-ci', -- Indent switch cases
        '-sr', -- Space after redirects
      },
      stdin = true,
    },
  },
}
