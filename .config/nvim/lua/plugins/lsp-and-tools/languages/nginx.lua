-- nginx.lua
return {
  mason = { 'nginx-language-server' }, -- For LSP support
  lsp = {
    nginxls = {},
  },
  formatters = {
    nginx = { 'nginxfmt' },
  },
  formatter_options = {
    nginxfmt = {
      command = 'nginxfmt',
      args = { '--indent=4', '--dontjoin' },
      stdin = true,
    },
  },
}
