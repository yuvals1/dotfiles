return {
  "folke/twilight.nvim",
  cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
  keys = {
    { "<leader>tw", "<cmd>Twilight<cr>", desc = "Toggle Twilight" },
  },
  opts = {
    dimming = {
      alpha = 0.25,
      color = { "Normal", "#ffffff" },
      term_bg = "#000000",
      inactive = false,
    },
    context = 15,
    treesitter = true,
    expand = {
      "function",
      "method",
      "table",
      "if_statement",
      "for_statement",
      "while_statement",
      "class",
      "struct",
    },
    exclude = {},
  },
}