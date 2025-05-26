return {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    animate = {
      duration = 10,
      easing = 'quad',
      fps = 144,
    },
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        { section = 'header' },
        { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        { section = 'startup' },
      },
    },
    indent = { enabled = true },
    input = { enabled = true, noautocmd = true, b = { completion = false } },
    notifier = { enabled = true, style = 'compact', timeout = 5000 },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = false },
  },
  keys = {
    {
      '<leader>gl',
      function()
        Snacks.lazygit()
      end,
      desc = '[L]azy[G]it',
    },
  },
}
