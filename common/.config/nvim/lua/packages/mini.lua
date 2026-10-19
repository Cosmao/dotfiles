local utils = require 'utils'
vim.pack.add { { src = 'https://github.com/nvim-mini/mini.nvim', version = 'stable' } }

require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup()
require('mini.files').setup()
require('mini.bufremove').setup()
require('mini.statusline').setup {
  ---@diagnostic disable-next-line: duplicate-set-field
}
require('mini.tabline').setup {
  show_icons = true,
  format = nil,
}

utils.set_keymaps {
  { 'n', '<leader>m', ':lua MiniFiles.open()<CR>', desc = 'Open MiniFiles' },
  { 'n', '<TAB>', ':bnext<CR>', desc = 'Next tab' },
  { 'n', '<S-TAB>', ':bprevious<CR>', desc = 'Previous tab' },
  { 'n', '<leader>bn', ':enew<CR>', desc = '[B]uffer [N]ew' },
  {
    'n',
    '<leader>x',
    function()
      MiniBufremove.delete()
    end,
    desc = 'Close buffer',
  },
}
