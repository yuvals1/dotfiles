return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function(_, opts)
    -- Enable flash for regular search
    opts.modes = {
      search = {
        enabled = true,
      },
    }
    require('flash').setup(opts)
  end,
  -- stylua: ignore
  keys = {
    { "m", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "M", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}