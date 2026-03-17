local theme_file = vim.fn.stdpath 'data' .. '/colorscheme'

return {
  { 'catppuccin/nvim', name = 'catppuccin' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      local f = io.open(theme_file, 'r')
      local theme = f and f:read '*l' or 'tokyonight-night'
      if f then
        f:close()
      end

      local transparent = theme == 'tokyonight-transparent'
      require('tokyonight').setup {
        transparent = transparent,
        styles = { comments = { italic = false } },
      }

      -- Load tokyonight-night directly when transparent to avoid nested
      -- :colorscheme calls which break highlight groups on startup
      local load_theme = transparent and 'tokyonight-night' or theme
      if not pcall(vim.cmd.colorscheme, load_theme) then
        vim.cmd.colorscheme 'tokyonight-night'
      end
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
