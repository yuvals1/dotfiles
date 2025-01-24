-- ~/.config/yazi/plugins/star_linemode.yazi/main.lua
return {
  -- Store bookmarks in state
  state = {
    bookmarks = {},
  },

  -- Read bookmarks file and store paths
  load_bookmarks = function(self)
    local home = os.getenv 'HOME'
    local bookmark_file = home .. '/.config/yazi/bookmark'

    local file = io.open(bookmark_file, 'r')
    if not file then
      ya.notify { title = 'Star Linemode', content = 'Could not open bookmark file', level = 'error' }
      return
    end

    -- Clear existing bookmarks
    self.state.bookmarks = {}

    -- Read each line and store the path
    for line in file:lines() do
      local _, path = line:match '([^\t]+)\t([^\t]+)'
      if path then
        self.state.bookmarks[path] = true
      end
    end
    file:close()
  end,

  setup = function(self, opts)
    -- Load bookmarks initially
    self:load_bookmarks()

    opts = opts or {}
    opts.order = opts.order or 1500

    -- Add our custom element to the linemode
    Linemode:children_add(function(this)
      local file_path = tostring(this._file.url)
      -- Show a star if the file is bookmarked
      if self.state.bookmarks[file_path] then
        return ui.Line ' ★'
      end
      return ui.Line ''
    end, opts.order)
  end,
}
