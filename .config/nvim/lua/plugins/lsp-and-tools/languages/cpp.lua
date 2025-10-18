-- cpp.lua

local function resolve_dir(fname)
  if type(fname) == 'number' then
    fname = vim.api.nvim_buf_get_name(fname)
  end
  if not fname or fname == '' then
    return vim.loop.cwd()
  end
  local stat = vim.uv.fs_stat(fname)
  if stat and stat.type == 'directory' then
    return fname
  end
  local dir = vim.fs.dirname(fname)
  return dir or vim.loop.cwd()
end

return {
  mason = { 'clangd', 'clang-format' },
  lsp = {
    clangd = {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--completion-style=detailed',
        '--header-insertion=iwyu',
      },
      capabilities = {
        offsetEncoding = { 'utf-16' },
      },
      root_dir = function(fname)
        local markers = {
          'compile_commands.json',
          'compile_flags.txt',
          'Makefile',
          '.git',
        }
        local dir = resolve_dir(fname)
        local match = vim.fs.find(markers, { path = dir, upward = true })[1]
        if match then
          return vim.fs.dirname(match)
        end
        return dir
      end,
    },
  },
  formatters = {
    cpp = { 'clang-format' },
  },
}
