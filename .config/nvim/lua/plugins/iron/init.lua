-- File: lua/plugins/iron/init.lua

return {
  'Vigemus/iron.nvim',
  event = 'VeryLazy',
  config = function()
    local iron = require 'iron.core'
    local view = require 'iron.view'
    local fts = require 'iron.fts'

    local repl = require 'plugins.iron.repl'
    local executor = require 'plugins.iron.executor'
    local keymaps = require 'plugins.iron.keymaps'
    local autocmds = require 'plugins.iron.autocmds'
    local execution_tracker = require 'plugins.iron.execution_tracker'

    vim.api.nvim_command 'highlight IronExecutedSign guifg=#2ecc71'

    vim.api.nvim_create_user_command('IronCleanSigns', execution_tracker.clean_execution_marks, {})
    vim.api.nvim_create_user_command('IronClearAndRestart', repl.clear_and_restart, {})

    -- Add a new configuration option
    vim.g.iron_repl_position = vim.g.iron_repl_position or 'right' -- Default to right

    -- Add a command to toggle REPL position
    vim.api.nvim_create_user_command('IronToggleREPLPosition', function()
      if vim.g.iron_repl_position == 'right' then
        vim.g.iron_repl_position = 'bottom'
        print 'REPL position set to bottom'
      else
        vim.g.iron_repl_position = 'right'
        print 'REPL position set to right'
      end
    end, {})

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
        exit = '<space>jq',
        -- visual_send = '<space>jv',
      },
      highlight = { italic = true },
      ignore_blank_lines = true,
    }

    keymaps.setup(iron, executor)
    autocmds.setup()
  end,
}
