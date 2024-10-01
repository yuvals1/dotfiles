-- toml.lua
return {
  mason = { 'taplo' },
  lsp = {
    taplo = {},
  },
  formatters = {
    toml = { 'taplo' },
  },
  linters = {
    -- You can add TOML linters here if desired.
  },
}

