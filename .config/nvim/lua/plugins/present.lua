return {
  "Chaitanyabsprip/present.nvim",
  opts = {
    default_mappings = true,
    kitty = {
      normal_font_size = 12,
      zoomed_font_size = 28,
    },
  },
  keys = {
    -- Slide navigation
    { "]b", ":bnext<CR>", desc = "Next slide", silent = true },
    { "[b", ":bprevious<CR>", desc = "Previous slide", silent = true },
  },
}
