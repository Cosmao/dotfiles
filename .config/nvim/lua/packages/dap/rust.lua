local dap = require 'dap'
local cargo = require 'packages.dap.common'

local function get_cargo_project()
  local projects = vim.g.projects or {}
  for _, p in ipairs(projects) do
    if p.type == 'cargo' then
      return p
    end
  end
  return nil
end

dap.adapters.gdb = {
  type = 'executable',
  command = 'rust-gdb',
  args = { '--interpreter=dap' },
}

dap.configurations.rust = dap.configurations.rust or {}
table.insert(dap.configurations.rust, {
  type = 'gdb',
  request = 'launch',
  name = 'Debug native (rust-gdb)',
  program = function()
    local p = get_cargo_project()
    local path = p and cargo.binary_path(p)
      or (vim.fn.getcwd() .. '/target/debug/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t'))
    vim.notify('DAP binary: ' .. path, vim.log.levels.INFO)
    return path
  end,
  cwd = function()
    local p = get_cargo_project()
    return p and cargo.cargo_cwd(p) or vim.fn.getcwd()
  end,
  stopAtBeginningOfMainSubprogram = true,
})
