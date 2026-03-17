vim.cmd.colorscheme 'tokyonight-night'

local groups = { 'Normal', 'NormalNC', 'NormalFloat', 'SignColumn', 'StatusLine', 'StatusLineNC' }
for _, group in ipairs(groups) do
  vim.api.nvim_set_hl(0, group, { bg = 'none' })
end
