local utils = require 'utils'
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {
  styles = {
    notification = { wo = { wrap = true } },
  },
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
  notifier = {
    enabled = true,
    timeout = 5000,
    style = 'compact',
    top_down = true,
    width = { min = 50, max = 0.4 },
  },
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
  {
    'n',
    '<leader>fn',
    function()
      Snacks.notifier.show_history()
    end,
    desc = '[F]ind [N]otifications',
  },
}
