local M = {}

function M.set_keymaps(key_maps)
  for _, map in pairs(key_maps) do
    local opts = {}
    for k, v in pairs(map) do
      if type(k) == 'string' then
        opts[k] = v
      end
    end
    vim.keymap.set(map[1], map[2], map[3], opts)
  end
end

return M
