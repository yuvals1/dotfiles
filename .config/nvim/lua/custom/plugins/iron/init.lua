-- File: lua/custom/plugins/iron/init.lua

local function execute_python_extractor(line_number, command)
  local python_path = vim.g.python3_host_prog
  local script_path = vim.fn.expand '~/.config/nvim/lua/custom/plugins/iron/code_block_extractor.py'

  if vim.fn.filereadable(script_path) == 0 then
    vim.api.nvim_echo({ { string.format('Error: Script not found at %s', script_path), 'ErrorMsg' } }, false, {})
    return
  end

  local buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  local tmp_file = vim.fn.tempname()
  local tmp_fd = io.open(tmp_file, 'w')
  tmp_fd:write(buffer_content)
  tmp_fd:close()

  local cmd = string.format('%s %s %d %s < %s', python_path, script_path, line_number, command, tmp_file)
  local output = vim.fn.system(cmd)

  os.remove(tmp_file)
  return output
end

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

    -- Modify the executor.smart_execute function to use Python AST
    executor.smart_execute = function()
      if vim.bo.filetype ~= 'python' then
        print 'This function is only for Python files.'
        return
      end

      local current_line = vim.fn.line '.'
      local code_block = execute_python_extractor(current_line, 'block')
      local range = execute_python_extractor(current_line, 'range')
      local start_line, end_line = range:match '(%d+),(%d+)'

      repl.send_to_repl(code_block, tonumber(start_line), tonumber(end_line), 'smart')
    end

    -- Modify the executor.smart_execute_and_move function
    executor.smart_execute_and_move = function()
      executor.smart_execute()
      local range = execute_python_extractor(vim.fn.line '.', 'range')
      local _, end_line = range:match '(%d+),(%d+)'
      vim.api.nvim_win_set_cursor(0, { tonumber(end_line) + 1, 0 })
    end

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
