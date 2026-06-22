local dap = require 'dap'
local cargo = require 'packages.dap.common'

local function get_probe_rs_project()
  local projects = vim.g.projects or {}
  for _, p in ipairs(projects) do
    if p.type == 'cargo' and p.chip then
      return p
    end
  end
  return nil
end

-- Start via overseer: <leader>or → Project → probe-rs: DAP server
dap.adapters.probe_rs = {
  type = 'server',
  host = '127.0.0.1',
  port = 50000,
}

dap.configurations.rust = dap.configurations.rust or {}
table.insert(dap.configurations.rust, {
  type = 'probe_rs',
  request = 'launch',
  name = 'Flash and debug (probe-rs)',
  cwd = function()
    local p = get_probe_rs_project()
    return p and cargo.cargo_cwd(p) or '${workspaceFolder}'
  end,
  chip = function()
    local p = get_probe_rs_project()
    return p and p.chip or 'STM32F411CEUx'
  end,
  flashingConfig = {
    flashingEnabled = true,
    resetAfterFlashing = true,
    haltAfterReset = true,
  },
  coreConfigs = {
    {
      coreIndex = 0,
      programBinaryFile = function()
        local p = get_probe_rs_project()
        return p and cargo.binary_path(p) or '${workspaceFolder}/target/debug/${workspaceFolderBasename}'
      end,
    },
  },
})
