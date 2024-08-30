return {
  'karb94/neoscroll.nvim',
  event = 'VeryLazy',
  config = function()
    require('neoscroll').setup {
      -- Remove the default mappings
      mappings = {},
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = nil, -- Use default easing function
      pre_hook = nil,
      post_hook = nil,
      performance_mode = false,
    }

    local t = {}
    -- Scroll 2 lines at a time, with a short duration for a snappy feel
    t['<C-u>'] = { 'scroll', { '-3', 'true', '50' } }
    t['<C-d>'] = { 'scroll', { '3', 'true', '50' } }
    -- Scroll 10 lines for <C-b> and <C-f>
    -- t['<C-b>'] = { 'scroll', { '-10', 'true', '100' } }
    -- t['<C-f>'] = { 'scroll', { '10', 'true', '100' } }
    -- Keep <C-y> and <C-e> as single line scrolls
    -- t['<C-y>'] = { 'scroll', { '-1', 'false', '50' } }
    -- t['<C-e>'] = { 'scroll', { '1', 'false', '50' } }
    -- Quick centering
    t['zt'] = { 'zt', { '100' } }
    t['zz'] = { 'zz', { '100' } }
    t['zb'] = { 'zb', { '100' } }

    require('neoscroll.config').set_mappings(t)
  end,
}
