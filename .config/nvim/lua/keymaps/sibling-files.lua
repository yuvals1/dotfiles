local function list_sibling_files(directory)
  local entries = vim.fn.readdir(directory)
  local files = {}

  for _, name in ipairs(entries) do
    if not name:match('^%.') then -- skip hidden files
      local path = directory .. '/' .. name
      local stat = vim.loop.fs_stat(path)
      if stat and stat.type == 'file' then
        table.insert(files, name)
      end
    end
  end

  table.sort(files)
  return files
end

local function jump_to_sibling_file(offset)
  local current_path = vim.fn.expand('%:p')
  if current_path == nil or current_path == '' then
    vim.notify('No current file', vim.log.levels.WARN)
    return
  end

  local directory = vim.fn.fnamemodify(current_path, ':h')
  local filename = vim.fn.fnamemodify(current_path, ':t')

  local files = list_sibling_files(directory)
  if #files == 0 then
    vim.notify('No files in directory', vim.log.levels.WARN)
    return
  end

  local current_index = nil
  for i, f in ipairs(files) do
    if f == filename then
      current_index = i
      break
    end
  end

  if not current_index then
    vim.notify('Current file not found among directory files', vim.log.levels.WARN)
    return
  end

  local target_index = current_index + offset
  if target_index < 1 or target_index > #files then
    vim.notify(offset > 0 and 'No next file' or 'No previous file', vim.log.levels.INFO)
    return
  end

  local target_path = directory .. '/' .. files[target_index]
  vim.cmd('edit ' .. vim.fn.fnameescape(target_path))
end

vim.keymap.set('n', ']f', function()
  jump_to_sibling_file(1)
end, { desc = 'Edit next file in directory' })

vim.keymap.set('n', '[f', function()
  jump_to_sibling_file(-1)
end, { desc = 'Edit previous file in directory' })
