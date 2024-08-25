return {
  'goolord/alpha-nvim',
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Set custom header
    dashboard.section.header.val = {
      [[                                                     ]],
      [[ ██╗   ██╗██╗   ██╗██╗   ██╗ █████╗ ██╗     ███████╗ ]],
      [[ ╚██╗ ██╔╝██║   ██║██║   ██║██╔══██╗██║     ██╔════╝ ]],
      [[  ╚████╔╝ ██║   ██║██║   ██║███████║██║     ███████╗ ]],
      [[   ╚██╔╝  ██║   ██║╚██╗ ██╔╝██╔══██║██║     ╚════██║ ]],
      [[    ██║   ╚██████╔╝ ╚████╔╝ ██║  ██║███████╗███████║ ]],
      [[    ╚═╝    ╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚══════╝╚══════╝ ]],
      [[                                                     ]],
      [[                    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
      [[                    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
      [[                    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
      [[                    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
      [[                    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
      [[                    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      [[                                                     ]],
    }

    -- Clear other sections
    dashboard.section.buttons.val = {}
    dashboard.section.footer.val = {}

    -- Set layout to only include the header
    dashboard.config.layout = {
      { type = 'padding', val = 2 },
      dashboard.section.header,
      { type = 'padding', val = 2 },
    }

    -- Send config to alpha
    alpha.setup(dashboard.config)

    -- Disable folding on alpha buffer
    vim.cmd [[
      autocmd FileType alpha setlocal nofoldenable
    ]]
  end,
}
