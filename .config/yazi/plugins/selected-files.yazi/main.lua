local toggle_ui = ya.sync(function(self)
  if self.children then
    Modal:children_remove(self.children)
    self.children = nil
  else
    self.children = Modal:children_add(self, 10)
  end
  ya.render()
end)

-- Debug helper to print all properties of a table
local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"' .. k .. '"'
      end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

-- Define M with keys
local M = {
  _id = 'selected-modal',
  keys = {
    { on = 'q', run = 'quit' },
  },
}

function M:new(area)
  self:layout(area)
  return self
end

function M:layout(area)
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

function M:get_selected_files()
  local message = 'Selected files:\n'
  local i = 1
  for _, file in pairs(cx.active.selected) do
    message = message .. i .. '. ' .. tostring(file) .. '\n'
    i = i + 1
  end
  return message
end

function M:entry(job)
  toggle_ui()

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
  return {
    ui.Clear(self._area),
    ui.Border(ui.Border.ALL):area(self._area):type(ui.Border.ROUNDED),
    ui.Text(self:get_selected_files()):area(self._area:pad(ui.Pad(1, 2, 1, 2))),
  }
end

function M:click() end
function M:scroll() end
function M:touch() end

return M
