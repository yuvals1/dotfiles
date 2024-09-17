require('git'):setup {}
require('full-border'):setup()
require('mactag'):setup {
  -- You can change the colors of the tags here
  colors = {
    Red = '#ee7b70',
    Orange = '#f5bd5c',
    Yellow = '#fbe764',
    Green = '#91fc87',
    Blue = '#5fa3f8',
    Purple = '#cb88f8',
    Gray = '#b5b5b9',
  },
}
require('starship'):setup()
