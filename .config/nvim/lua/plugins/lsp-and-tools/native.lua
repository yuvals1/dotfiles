local M = {}

local function normalize_path(path)
  if type(path) == 'number' then
    path = vim.api.nvim_buf_get_name(path)
  end
  return path
end

local function path_dir(path)
  path = normalize_path(path)
  if not path or path == '' then
    return nil
  end
  local stat = vim.uv.fs_stat(path)
  if stat and stat.type == 'directory' then
    return path
  end
  return vim.fs.dirname(path)
end

local function git_root(dir)
  local found = vim.fs.find('.git', { path = dir, upward = true })[1]
  return found and vim.fs.dirname(found) or nil
end

local function first_root(markers, dir)
  local found = vim.fs.find(markers, { path = dir, upward = true })[1]
  return found and vim.fs.dirname(found) or nil
end

local function resolve_dir(fname)
  fname = normalize_path(fname)
  local dir = path_dir(fname)
  if dir and dir ~= '' then
    return dir
  end
  return vim.loop.cwd()
end

local default_configs = {
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({
        '.luarc.json',
        '.luarc.jsonc',
        '.luacheckrc',
        '.stylua.toml',
        'stylua.toml',
        'selene.toml',
        'selene.yml',
      }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
  },
  pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        'pyrightconfig.json',
      }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  },
  marksman = {
    cmd = { 'marksman', 'server' },
    filetypes = { 'markdown', 'markdown.mdx' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({ '.marksman.toml' }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
  },
  jsonls = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    init_options = { provideFormatter = true },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      return git_root(dir) or dir
    end,
    single_file_support = true,
  },
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'bash', 'sh' },
    settings = {
      bashIde = {
        globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
      },
    },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      return git_root(dir) or dir
    end,
    single_file_support = true,
  },
  lemminx = {
    cmd = { 'lemminx' },
    filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      return git_root(dir) or dir
    end,
    single_file_support = true,
  },
  taplo = {
    cmd = { 'taplo', 'lsp', 'stdio' },
    filetypes = { 'toml' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      return git_root(dir) or dir
    end,
    single_file_support = true,
  },
  ts_ls = {
    init_options = { hostInfo = 'neovim' },
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({ 'tsconfig.json', 'jsconfig.json', 'package.json' }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
  },
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({ 'go.work', 'go.mod' }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
  },
  dockerls = {
    cmd = { 'docker-langserver', '--stdio' },
    filetypes = { 'dockerfile' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({ 'Dockerfile' }, dir)
      return root or dir
    end,
    single_file_support = true,
  },
  clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
      }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
    capabilities = {
      textDocument = {
        completion = {
          editsNearCursor = true,
        },
      },
      offsetEncoding = { 'utf-8', 'utf-16' },
    },
  },
  svelte = {
    cmd = { 'svelteserver', '--stdio' },
    filetypes = { 'svelte' },
    root_dir = function(fname)
      local dir = resolve_dir(fname)
      local root = first_root({ 'package.json' }, dir) or git_root(dir)
      return root or dir
    end,
    single_file_support = true,
  },
}

function M.setup(configs)
  local servers = configs and configs.lsp_servers or {}
  for server, user_conf in pairs(servers) do
    local base = default_configs[server]
    local merged
    if base then
      merged = vim.tbl_deep_extend('force', vim.deepcopy(base), user_conf)
    else
      merged = vim.deepcopy(user_conf)
    end
    if merged.root_markers and not merged.root_dir then
      local markers = merged.root_markers
      merged.root_dir = function(fname)
        local dir = resolve_dir(fname)
        local root = first_root(markers, dir) or git_root(dir)
        return root or dir
      end
      merged.root_markers = nil
    end
    vim.lsp.config[server] = merged
    vim.lsp.enable(server)
  end
end

return M
