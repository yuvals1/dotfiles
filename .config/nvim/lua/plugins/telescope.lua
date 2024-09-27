return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    {
      '<leader>sh',
      function()
        require('telescope.builtin').help_tags()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sk',
      function()
        require('telescope.builtin').keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>sf',
      function()
        require('telescope.builtin').find_files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>ss',
      function()
        require('telescope.builtin').builtin()
      end,
      desc = '[S]earch [S]elect Telescope',
    },
    {
      '<leader>sw',
      function()
        require('telescope.builtin').grep_string()
      end,
      desc = '[S]earch current [W]ord',
    },
    {
      '<leader>sG',
      function()
        require('telescope.builtin').live_grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sd',
      function()
        require('telescope.builtin').diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        require('telescope.builtin').resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>s.',
      function()
        require('telescope.builtin').oldfiles()
      end,
      desc = '[S]earch Recent Files ("." for repeat)',
    },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>sn',
      function()
        require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = '[S]earch [N]eovim files',
    },
  },
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      lazy = true,
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim', lazy = true },
    { 'nvim-tree/nvim-web-devicons', lazy = true, enabled = vim.g.have_nerd_font },
  },
  config = function()
    vim.defer_fn(function()
      local telescope = require 'telescope'
      local builtin = require 'telescope.builtin'
      telescope.setup {
        defaults = {
          path_display = function(opts, path)
            local tail = require('telescope.utils').path_tail(path)
            local relative_path = vim.fn.fnamemodify(path, ':~:.')
            if relative_path ~= tail then
              return string.format('%s |       %s', tail, relative_path), { { { 1, #tail }, 'Constant' } }
            else
              return tail, { { { 1, #tail }, 'Constant' } }
            end
          end,
          layout_strategy = 'vertical',
          layout_config = {
            vertical = {
              width = 0.8,
              height = 0.9,
              preview_height = 0.5,
              preview_cutoff = 0,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
          },
          live_grep = {
            additional_args = function()
              return { '--hidden' }
            end,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Lazy load extensions
      local function load_extension(name)
        return function()
          telescope.load_extension(name)
          telescope.extensions[name][name]()
        end
      end

      -- You can call these functions when you need to use the extensions
      -- For example, you could add them to your keymaps:
      -- vim.keymap.set('n', '<leader>sf', load_extension('fzf'), { desc = 'Telescope FZF' })
      -- vim.keymap.set('n', '<leader>su', load_extension('ui-select'), { desc = 'Telescope UI Select' })
    end, 100)
  end,
}
