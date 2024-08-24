-- File: lua/custom/plugins/iron/init.lua

return {
  'Vigemus/iron.nvim',
  event = 'VeryLazy',
  config = function()
    local iron = require 'iron.core'
    local view = require 'iron.view'
    local fts = require 'iron.fts'

    local custom_functions = require 'custom.plugins.iron.functions'
    local keymaps = require 'custom.plugins.iron.keymaps'
    local autocmds = require 'custom.plugins.iron.autocmds'

    iron.setup {
      config = {
        visibility = require('iron.visibility').toggle,
        scratch_repl = true,
        repl_definition = {
          sh = {
            command = { 'zsh' },
          },
          python = fts.python.ipython,
        },
        repl_open_cmd = custom_functions.custom_repl_open_cmd,
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

    keymaps.setup(iron, custom_functions)
    autocmds.setup()
  end,
}
