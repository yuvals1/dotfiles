-- mason_setup.lua

local M = {}

M.setup = function()
  require('mason').setup()

  -- LSP servers to ensure are installed (use LSP server names)
  local ensure_installed_servers = vim.tbl_keys(require('plugins.lsp.servers').servers or {})

  -- Add any additional LSP servers you want to ensure are installed
  vim.list_extend(ensure_installed_servers, {
    -- Example: 'pyright', 'clangd'
  })

  -- Set up mason-lspconfig to ensure LSP servers are installed
  require('mason-lspconfig').setup {
    ensure_installed = ensure_installed_servers,
    handlers = {
      function(server_name)
        local server = require('plugins.lsp.servers').servers[server_name] or {}
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }

  -- Non-LSP tools to ensure are installed via mason
  local ensure_installed_tools = {
    'stylua',
    'markdownlint',
    -- Add other tools like formatters or linters here
  }

  -- Use mason-tool-installer to ensure tools are installed
  require('mason-tool-installer').setup {
    ensure_installed = ensure_installed_tools,
    auto_update = false,
    run_on_start = true,
  }

  -- Install pylsp-mypy into the python-lsp-server environment
  local mason_registry = require 'mason-registry'

  local function install_pylsp_mypy()
    local pylsp_pkg = mason_registry.get_package 'python-lsp-server'
    if not pylsp_pkg:is_installed() then
      pylsp_pkg:install():once('closed', function()
        if pylsp_pkg:is_installed() then
          install_pylsp_mypy()
        end
      end)
      return
    end

    local install_path = pylsp_pkg:get_install_path()
    local venv_path = install_path .. '/venv'
    local pip_exec = venv_path .. '/bin/pip'

    -- Check if pylsp-mypy is already installed
    local handle = io.popen(pip_exec .. ' show pylsp-mypy')
    local result = handle:read '*a'
    handle:close()

    if result == '' then
      -- Install pylsp-mypy
      vim.fn.jobstart({ pip_exec, 'install', 'pylsp-mypy' }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data then
            print(table.concat(data, '\n'))
          end
        end,
        on_stderr = function(_, data)
          if data then
            print(table.concat(data, '\n'))
          end
        end,
        on_exit = function()
          print 'Installed pylsp-mypy'
        end,
      })
    else
      print 'pylsp-mypy is already installed'
    end
  end

  -- Call the function to install pylsp-mypy
  install_pylsp_mypy()
end

return M
