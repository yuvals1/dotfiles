-- bash.lua
return {
  mason = {
    'bash-language-server', -- LSP
    'shellcheck', -- Linter
    'shfmt', -- Formatter
  },

  -- LSP configuration
  lsp = {
    bashls = {
      filetypes = { 'sh', 'bash' },
    },
  },

  -- Which formatter to use for which filetypes
  formatters = {
    sh = { 'shfmt' },
    bash = { 'shfmt' },
  },

  -- Which linter to use for which filetypes
  linters = {
    sh = { 'shellcheck' },
    bash = { 'shellcheck' },
  },

  -- Formatter-specific configuration
  formatter_options = {
    ['shfmt'] = {
      args = {
        '-i',
        '2', -- Default 2 spaces indentation if no .editorconfig
        '-bn', -- Binary ops may start a line (more readable for long conditions)
        '-ci', -- Indent switch cases
        '-sr', -- Space after redirects
      },
    },
  },

  -- Linter-specific configuration
  linter_options = {
    shellcheck = {
      args = {
        '--external-sources', -- Allow 'source' outside of FILES
        '--source-path=SCRIPTDIR', -- Look for sourced files in same dir as script
        '--format=gcc', -- Format output for editor integration
        '--shell=bash', -- Specify bash as shell dialect
        '--severity=style', -- Include style suggestions
        '--enable=all', -- Enable all optional checks
      },
    },
  },
}
