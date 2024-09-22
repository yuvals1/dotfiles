-- ~/.config/nvim/lua/plugins/lsp/mason_setup.lua

local M = {}

M.setup = function()
  -- Initialize Mason.nvim
  require('mason').setup()

  -- Retrieve the list of LSP servers from servers.lua
  local servers = vim.tbl_keys(require('plugins.lsp.servers').servers or {})

  -- Initialize mason-lspconfig with the servers to ensure are installed
  require('mason-lspconfig').setup {
    ensure_installed = servers, -- Use correct server names ("pylsp", "pyright", etc.)
    handlers = {
      function(server_name)
        -- Retrieve server-specific configurations from servers.lua
        local server = require('plugins.lsp.servers').servers[server_name] or {}
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }

  -- List of non-LSP tools to ensure are installed via mason-tool-installer
  local ensure_installed_tools = {
    'stylua', -- Lua formatter
    'markdownlint', -- Markdown linter
    'black', -- Python formatter
    'isort', -- Import sorter for Python
    -- Add other formatters or linters as needed
  }

  -- Initialize mason-tool-installer to ensure tools are installed
  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed_tools,
    auto_update = false,
    run_on_start = true,
  }

  -- Function to install pylsp-mypy into the python-lsp-server's virtual environment
  local mason_registry = require 'mason-registry'

  local function install_pylsp_mypy()
    -- Map server names to package names
    local server_package_map = {
      pylsp = 'python-lsp-server',
      -- Add other mappings if needed
    }

    local server_name = 'pylsp'
    local package_name = server_package_map[server_name]

    if not package_name then
      vim.notify('No package mapping found for server: ' .. server_name, vim.log.levels.ERROR)
      return
    end

    local pkg = mason_registry.get_package(package_name)

    if not pkg then
      vim.notify('Package not found in Mason registry: ' .. package_name, vim.log.levels.ERROR)
      return
    end

    if not pkg:is_installed() then
      -- Install python-lsp-server if not already installed
      pkg:install():once('closed', function()
        if pkg:is_installed() then
          -- After installing python-lsp-server, install pylsp-mypy
          install_pylsp_mypy()
        end
      end)
      return
    end

    local install_path = pkg:get_install_path()
    local venv_path = install_path .. '/venv' -- Mason typically installs in a 'venv' directory
    local pip_exec = venv_path .. '/bin/pip' -- For Unix-based systems
    -- For Windows, uncomment the following line and comment out the Unix line above
    -- local pip_exec = venv_path .. '\\Scripts\\pip.exe'

    -- Check if pylsp-mypy is already installed
    local handle = io.popen(pip_exec .. ' show pylsp-mypy')
    local result = handle:read '*a'
    handle:close()

    if result == '' then
      -- Install pylsp-mypy
      vim.fn.jobstart({ pip_exec, 'install', 'pylsp-mypy' }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
          if data then
            print(table.concat(data, '\n'))
          end
        end,
        on_stderr = function(_, data)
          if data then
            vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR)
          end
        end,
        on_exit = function()
          vim.notify('Installed pylsp-mypy', vim.log.levels.INFO)
        end,
      })
    else
      vim.notify('pylsp-mypy is already installed', vim.log.levels.INFO)
    end
  end

  -- Initiate the installation of pylsp-mypy
  install_pylsp_mypy()
end

return M
