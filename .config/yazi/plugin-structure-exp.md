# plugin return the plugin table:
  return {
      setup = setup,
      fetch = fetch,
      entry = entry
  }


# Example: Simple File Counter Plugin
```lua

  -- This plugin counts how many times you've viewed each file

  -- SETUP: Called ONCE when Yazi starts
  local function setup(st, opts)
      st.view_counts = {}  -- Create empty counter storage
      st.show_message = opts.show_message or false  -- Get option from init.lua

      -- This runs once and creates persistent storage
      ya.notify {
          title = "File Counter",
          content = "Plugin loaded!",
      }
  end

  -- FETCH: Called when Yazi needs to update file info
  local function fetch(st, job)
      -- job.files = list of files that need updating

      for _, file in ipairs(job.files) do
          local path = tostring(file.url)

          -- Initialize count if not exists
          if not st.view_counts[path] then
              st.view_counts[path] = 0
          end
      end

      -- This updates the display somehow
  end

  -- ENTRY: Called when user presses the keybind
  local function entry(self, job)
      -- job.args[1] = action like "increment" or "show" or "reset"

      if job.args[1] == "increment" then
          -- We want to increase counter for current file
          -- BUT we can't access st.view_counts here!
          -- So we need ya.sync...

          ya.notify {
              title = "Clicked",
              content = "You pressed the key!",
          }

      elseif job.args[1] == "reset" then
          -- Reset all counters
          ya.notify {
              title = "Reset",
              content = "Counters reset!",
          }
      end
  end

  -- Return the plugin table
  return {
      setup = setup,
      fetch = fetch,
      entry = entry
  }
```

  In init.lua:

```lua
  require("file-counter"):setup {
      show_message = true
  }
```

  In keymap.toml:

```toml
  [[manager.prepend_keymap]]
  on = "c"
  run = "plugin file-counter increment"
  desc = "Count this file view"

  [[manager.prepend_keymap]]
  on = "C"
  run = "plugin file-counter reset"
  desc = "Reset all counters"
```

  What happens:

  1. Yazi starts → setup() runs once → creates st.view_counts = {}
  2. User navigates to folder → fetch() runs → initializes counts for visible files
  3. User presses 'c' → entry() runs with args=["increment"] → shows notification
  4. User presses 'C' → entry() runs with args=["reset"] → shows notification

  The Key Point:

  - setup: Runs ONCE, sets up persistent storage, Run once automatically
  - fetch: Runs when Yazi needs to update file display, Run automatically when need to display files
  - entry: Runs EVERY time user presses a keybind, Trigger by user

  But notice: in entry, we can't actually access st.view_counts to increment it! That's why we need
  ya.sync - to bridge the gap between entry and the state.

