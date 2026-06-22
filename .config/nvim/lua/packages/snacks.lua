local utils = require 'utils'
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {
  animate = {
    duration = 10,
    fps = 120,
  },
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },

    },
  },

  indent = { enabled = true },
  input = { enabled = true, noautocmd = true, b = { completion = false } },
  notifier = { enabled = true, style = 'compact', timeout = 5000 },
  quickfile = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = false },
}

utils.set_keymaps {
  {
    'n',
    '<leader>gl',
    function()
      Snacks.lazygit()
    end,
    desc = '[L]azy[G]it',
  },
}
