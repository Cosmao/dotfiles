local theme_file = vim.fn.stdpath 'data' .. '/colorscheme'

return {
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }

      local f = io.open(theme_file, 'r')
      local theme = f and f:read '*l' or 'tokyonight-night'
      if f then
        f:close()
      end

      if not pcall(vim.cmd.colorscheme, theme) then
        vim.cmd.colorscheme 'tokyonight-night'
      end
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
