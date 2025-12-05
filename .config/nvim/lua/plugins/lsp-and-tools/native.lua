local M = {}

-- Helper function to find project root using markers
-- Returns the root directory or nil
local function find_root(bufnr, markers)
  return vim.fs.root(bufnr, markers)
end

-- Helper to get buffer directory as fallback
local function get_buffer_dir(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname and bufname ~= '' then
    return vim.fs.dirname(bufname)
  end
  return vim.uv.cwd()
end

-- Create a root_dir function that follows Neovim 0.11 native API pattern
-- For servers with single_file_support, we always call on_dir (with marker root or buffer dir)
local function make_root_dir_fn(markers)
  return function(bufnr, on_dir)
    local root = find_root(bufnr, markers)
    if root then
      on_dir(root)
    else
      -- Fallback to buffer directory for single-file support
      on_dir(get_buffer_dir(bufnr))
    end
  end
end

-- Default LSP configurations for Neovim 0.11 native API
local default_configs = {
  lua_ls = {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_dir = make_root_dir_fn {
      '.luarc.json',
      '.luarc.jsonc',
      '.luacheckrc',
      '.stylua.toml',
      'stylua.toml',
      'selene.toml',
      'selene.yml',
      '.git',
    },
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
      },
    },
  },
  pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_dir = make_root_dir_fn {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      'pyrightconfig.json',
      '.git',
    },
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
    root_dir = make_root_dir_fn { '.marksman.toml', '.git' },
  },
  jsonls = {
    cmd = { 'vscode-json-language-server', '--stdio' },
    filetypes = { 'json', 'jsonc' },
    init_options = { provideFormatter = true },
    root_dir = make_root_dir_fn { '.git' },
  },
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'bash', 'sh' },
    settings = {
      bashIde = {
        globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
      },
    },
    root_dir = make_root_dir_fn { '.git' },
  },
  lemminx = {
    cmd = { 'lemminx' },
    filetypes = { 'xml', 'xsd', 'xsl', 'xslt', 'svg' },
    root_dir = make_root_dir_fn { '.git' },
  },
  taplo = {
    cmd = { 'taplo', 'lsp', 'stdio' },
    filetypes = { 'toml' },
    root_dir = make_root_dir_fn { '.git' },
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
    root_dir = make_root_dir_fn { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  },
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_dir = make_root_dir_fn { 'go.work', 'go.mod', '.git' },
  },
  dockerls = {
    cmd = { 'docker-langserver', '--stdio' },
    filetypes = { 'dockerfile' },
    root_dir = make_root_dir_fn { 'Dockerfile', '.git' },
  },
  clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    root_dir = make_root_dir_fn {
      '.clangd',
      '.clang-tidy',
      '.clang-format',
      'compile_commands.json',
      'compile_flags.txt',
      'configure.ac',
      'Makefile',
      '.git',
    },
    capabilities = {
      textDocument = {
        completion = {
          editsNearCursor = true,
        },
      },
      offsetEncoding = { 'utf-16' },
    },
  },
  svelte = {
    cmd = { 'svelteserver', '--stdio' },
    filetypes = { 'svelte' },
    root_dir = make_root_dir_fn { 'svelte.config.js', 'package.json', '.git' },
  },
  yamlls = {
    cmd = { 'yaml-language-server', '--stdio' },
    filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
    root_dir = make_root_dir_fn { '.git' },
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

    -- If user provides root_markers but no root_dir, create a root_dir function
    if merged.root_markers and not merged.root_dir then
      local markers = merged.root_markers
      merged.root_dir = make_root_dir_fn(markers)
      merged.root_markers = nil
    end

    -- If user provides a root_dir function that returns a string (old style),
    -- wrap it in the new callback style
    if merged.root_dir and type(merged.root_dir) == 'function' then
      local original_fn = merged.root_dir
      -- Check if it's already a callback-style function by testing the arity
      -- We can't easily do this, so we assume any function with a name from default_configs is already correct
      -- For user-provided functions, we need to wrap them
      if not base or not base.root_dir then
        -- User provided a custom root_dir function, wrap it
        merged.root_dir = function(bufnr, on_dir)
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local result = original_fn(bufname)
          if result then
            on_dir(result)
          else
            on_dir(get_buffer_dir(bufnr))
          end
        end
      end
    end

    vim.lsp.config[server] = merged
    vim.lsp.enable(server)
  end
end

return M
