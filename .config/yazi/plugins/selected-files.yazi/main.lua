local toggle_ui = ya.sync(function(self)
  if self.children then
    Modal:children_remove(self.children)
    self.children = nil
  else
    self.children = Modal:children_add(self, 10)
  end
  ya.render()
end)

-- Define M with keys
local M = {
  _id = 'test-modal',
  keys = {
    { on = 'q', run = 'quit' },
  },
}

function M:new(area)
  self:layout(area) -- Notice this change from self._area = area
  return self
end

-- Add layout function
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

-- Change entry to handle events properly
function M:entry(job) -- Notice the job parameter
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
    ui.Text('Hello from test-modal!'):area(self._area:pad(ui.Pad(1, 2, 1, 2))),
  }
end

function M:click() end
function M:scroll() end
function M:touch() end

return M
