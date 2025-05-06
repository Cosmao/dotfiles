return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {
        options = {
          separator_style = 'slant',
        },
      }
    end,
    -- BufferLineCycleNext
    -- BufferLineCyclePrev
    keys = {
      {
        '<TAB>',
        ':BufferLineCycleNext<CR>',
        desc = 'Next buffer',
        silent = true,
      },
      {
        '<S-TAB>',
        ':BufferLineCyclePrev<CR>',
        desc = 'Previous buffer',
        silent = true,
      },
      {
        '<leader>x',
        ':bprevious | bdelete #<CR>',
        desc = 'Close buffer',
      },
    },
  },
}
