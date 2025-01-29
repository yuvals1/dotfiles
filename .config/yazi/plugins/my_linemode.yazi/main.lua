-- ~/.config/yazi/plugins/my_linemode.yazi/main.lua
return {
  setup = function(_, opts)
    opts = opts or {}
    opts.order = opts.order or 1500

    -- Add our custom element to the linemode
    Linemode:children_add(function(self)
      -- Just display the filename without brackets
      return ui.Line(self._file.name)
    end, opts.order)
  end,
}
