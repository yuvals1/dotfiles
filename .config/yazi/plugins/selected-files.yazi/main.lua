local toggle_ui = ya.sync(function(self)
  if self.children then
    Modal:children_remove(self.children)
    self.children = nil
  else
    self.children = Modal:children_add(self, 10)
  end
  ya.render()
end)

local update_selected = ya.sync(function(self)
  -- Get selected files from current manager
  local selected = {}
  for url, _ in pairs(cx.active.selected) do
    selected[#selected + 1] = {
      path = ya.readable_path(tostring(url)),
      size = ya.readable_size(fs.cha(url).len),
    }
  end

  self.selected = selected
  self.cursor = math.max(0, math.min(self.cursor or 0, #self.selected - 1))
  ya.render()
end)

local update_cursor = ya.sync(function(self, cursor)
  if #self.selected == 0 then
    self.cursor = 0
  else
    self.cursor = ya.clamp(0, self.cursor + cursor, #self.selected - 1)
  end
  ya.render()
end)

local M = {
  keys = {
    { on = 'q', run = 'quit' },
    { on = 'k', run = 'up' },
    { on = 'j', run = 'down' },
    { on = '<Up>', run = 'up' },
    { on = '<Down>', run = 'down' },
  },
}

function M:new(area)
  self:layout(area)
  return self
end

function M:layout(area)
  -- Create a centered modal window
  local chunks = ui.Layout()
    :constraints({
      ui.Constraint.Percentage(10),
      ui.Constraint.Percentage(80),
      ui.Constraint.Percentage(10),
    })
    :split(area)

  local chunks = ui.Layout()
    :direction(ui.Layout.HORIZONTAL)
    :constraints({
      ui.Constraint.Percentage(10),
      ui.Constraint.Percentage(80),
      ui.Constraint.Percentage(10),
    })
    :split(chunks[2])

  self._area = chunks[2]
end

function M:entry(job)
  toggle_ui()
  update_selected(self)

  local tx1, rx1 = ya.chan 'mpsc'
  local tx2, rx2 = ya.chan 'mpsc'

  function producer()
    while true do
      local cand = self.keys[ya.which { cands = self.keys, silent = true }]
      if cand then
        tx1:send(cand.run)
        if cand.run == 'quit' then
          toggle_ui()
          break
        end
      end
    end
  end

  function consumer1()
    repeat
      local run = rx1:recv()
      if run == 'quit' then
        tx2:send(run)
        break
      elseif run == 'up' then
        update_cursor(self, -1)
      elseif run == 'down' then
        update_cursor(self, 1)
      end
    until not run
  end

  function consumer2()
    repeat
      local run = rx2:recv()
      if run == 'quit' then
        break
      end
    until not run
  end

  ya.join(producer, consumer1, consumer2)
end

function M:reflow()
  return { self }
end

function M:redraw()
  local rows = {}
  for _, file in ipairs(self.selected or {}) do
    rows[#rows + 1] = ui.Row { file.path, file.size }
  end

  if #rows == 0 then
    return {
      ui.Clear(self._area),
      ui.Border(ui.Border.ALL):area(self._area):type(ui.Border.ROUNDED):style(ui.Style():fg 'blue'):title(ui.Line('Selected Files'):align(ui.Line.CENTER)),
      ui.Text('No files selected'):area(self._area:pad(ui.Pad(1, 2, 1, 2))):style(ui.Style():fg 'gray'),
    }
  end

  return {
    ui.Clear(self._area),
    ui.Border(ui.Border.ALL)
      :area(self._area)
      :type(ui.Border.ROUNDED)
      :style(ui.Style():fg 'blue')
      :title(ui.Line('Selected Files (' .. #rows .. ')'):align(ui.Line.CENTER)),
    ui.Table(rows)
      :area(self._area:pad(ui.Pad(1, 2, 1, 2)))
      :header(ui.Row({ 'Path', 'Size' }):style(ui.Style():bold()))
      :row(self.cursor)
      :row_style(ui.Style():fg('blue'):underline())
      :widths {
        ui.Constraint.Percentage(80),
        ui.Constraint.Length(10),
      },
  }
end

function M:click() end
function M:scroll() end
function M:touch() end

return M
