-- ~/.config/yazi/plugins/star_linemode.yazi/main.lua
return {
  state = {
    bookmarks = {},
  },

  load_bookmarks = function(self)
    local home = os.getenv 'HOME'
    local bookmark_file = home .. '/.config/yazi/bookmark'

    local file = io.open(bookmark_file, 'r')
    if not file then
      ya.notify { title = 'Star Linemode', content = 'Could not open bookmark file', level = 'error' }
      return
    end

    self.state.bookmarks = {}

    for line in file:lines() do
      local _, path = line:match '([^\t]+)\t([^\t]+)'
      if path then
        self.state.bookmarks[path] = true
      end
    end
    file:close()
  end,

  setup = function(self, opts)
    self:load_bookmarks()

    opts = opts or {}
    opts.order = opts.order or 1500

    -- Try different symbols by uncommenting one at a time:
    -- local symbol = ' 🔖' -- Bookmark (default)
    -- local symbol = " ♥"    -- Heart, classic favorite symbol
    local symbol = ' ⭐' -- Star mark
    -- local symbol = " ⚑"    -- Flag mark
    -- local symbol = ' 📌' -- Pin
    -- local symbol = " 📎"   -- Paperclip
    -- local symbol = " ⚐"    -- White flag
    -- local symbol = " ☆"    -- Open star
    -- local symbol = " ★"    -- Filled star
    -- local symbol = " ▶"    -- Triangle marker
    -- local symbol = " •"    -- Bullet
    -- local symbol = " ◉"    -- Large dot
    -- local symbol = " ✓"    -- Checkmark
    -- local symbol = " ✦"    -- Decorative star
    -- local symbol = " ⚡"   -- Lightning bolt

    local symbol_style = ui.Style():fg('yellow'):bold()

    Linemode:children_add(function(this)
      local file_path = tostring(this._file.url)
      if self.state.bookmarks[file_path] then
        return ui.Line { ui.Span(symbol):style(symbol_style) }
      end
      return ui.Line ''
    end, opts.order)
  end,
}
