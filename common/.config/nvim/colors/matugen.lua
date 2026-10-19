package.loaded['matugen_palette'] = nil
local ok, palette = pcall(require, 'matugen_palette')
if ok then
  require('mini.base16').setup { palette = palette }
end
