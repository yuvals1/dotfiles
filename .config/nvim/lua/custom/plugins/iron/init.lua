-- File: lua/custom/plugins/iron/init.lua

return {
  'Vigemus/iron.nvim',
  event = 'VeryLazy',
  config = function()
    local iron = require 'iron.core'
    local view = require 'iron.view'
    local fts = require 'iron.fts'

    local repl = require 'custom.plugins.iron.repl'
    local executor = require 'custom.plugins.iron.executor'
    local keymaps = require 'custom.plugins.iron.keymaps'
    local autocmds = require 'custom.plugins.iron.autocmds'
    local execution_tracker = require 'custom.plugins.iron.execution_tracker'

    vim.api.nvim_command 'highlight IronExecutedSign guifg=#2ecc71'

    vim.api.nvim_create_user_command('IronCleanSigns', execution_tracker.clean_execution_marks, {})
    vim.api.nvim_create_user_command('IronClearAndRestart', repl.clear_and_restart, {})

    iron.setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          sh = {
            command = { 'zsh' },
          },
          python = fts.python.ipython,
        },
        repl_open_cmd = repl.custom_repl_open_cmd,
      },
      keymaps = {
        send_file = '<space>ja',
        send_line = '<space>jl',
        send_until_cursor = '<space>jc',
        exit = '<space>jq',
        visual_send = '<space>jv',
      },
      highlight = { italic = true },
      ignore_blank_lines = true,
    }

    keymaps.setup(iron, executor)
    autocmds.setup()
  end,
}
