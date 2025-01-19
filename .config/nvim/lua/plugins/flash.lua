return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {},
  config = function(_, opts)
    -- Disable the 'char' mode to prevent overriding 'f', 't', and 'T'
    opts.modes = {
      char = {
        enabled = false,
      },
      search = {
        enabled = true,
        highlight = { backdrop = true },
      },
    }
    require('flash').setup(opts)
  end,
  -- stylua: ignore
  keys = {
    -- { "S", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "s", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter surround" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
