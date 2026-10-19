local theme_file = vim.fn.stdpath 'data' .. '/colorscheme'

vim.pack.add {
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' },
  { src = 'https://github.com/folke/tokyonight.nvim', name = 'tokyonight' },
}

require('tokyonight').setup { styles = { comments = { italic = false } } }

local f = io.open(theme_file, 'r')
local theme = f and f:read '*l' or 'tokyonight-night'
if f then
  f:close()
end

if not pcall(vim.cmd.colorscheme, theme) then
  vim.cmd.colorscheme 'tokyonight-night'
end
