local dap = require 'dap'
local cargo = require 'packages.dap.common'

local function get_probe_rs_project()
  local projects = vim.g.projects or {}
  for _, p in ipairs(projects) do
    -- A cargo project counts as flashable once a chip resolves (from its
    -- .cargo/config.toml runner, or an explicit p.chip override).
    if p.type == 'cargo' and cargo.chip(p) then
      return p
    end
  end
  return nil
end

-- nvim-dap launches its own `probe-rs dap-server` on a free port (${port}) for
-- each session and kills it when the session ends, so the probe is only held
-- while flashing/debugging. No long-running server task to start or clean up.
dap.adapters.probe_rs = {
  type = 'server',
  port = '${port}',
  executable = {
    command = 'probe-rs',
    args = { 'dap-server', '--port', '${port}' },
  },
}

-- Run `cargo build` via overseer, calling on_done(success) when it finishes.
local function build(project, on_done)
  local overseer = require 'overseer'
  local cmd = { 'cargo', 'build' }
  local target = cargo.target(project)
  if target then
    vim.list_extend(cmd, { '--target', target })
  end
  local task = overseer.new_task {
    name = 'cargo build (pre-debug) [' .. (project.name or 'cargo') .. ']',
    cmd = cmd,
    cwd = cargo.cargo_cwd(project),
  }
  task:subscribe('on_complete', function(_, status)
    if status ~= 'SUCCESS' then
      overseer.open { enter = false }
      vim.notify('Pre-debug build failed — launch aborted', vim.log.levels.ERROR)
    end
    on_done(status == 'SUCCESS')
  end)
  task:start()
end

dap.configurations.rust = dap.configurations.rust or {}
table.insert(dap.configurations.rust, {
  type = 'probe_rs',
  request = 'launch',
  name = 'Flash and debug (probe-rs)',
  -- `cwd` doubles as the pre-launch build gate. nvim-dap resolves every config
  -- value before sending `launch`, and a *top-level* value of `dap.ABORT`
  -- cancels the run (dap.lua only checks the top level, not nested fields). So
  -- we build here inside a coroutine — nvim-dap drives it (see eval_option),
  -- keeping the UI responsive — and abort the whole launch on build failure so
  -- a stale/missing binary is never flashed.
  cwd = function()
    return coroutine.create(function(parent_co)
      local p = get_probe_rs_project()
      if not p then
        return coroutine.resume(parent_co, '${workspaceFolder}')
      end
      build(p, function(ok)
        coroutine.resume(parent_co, ok and cargo.cargo_cwd(p) or dap.ABORT)
      end)
    end)
  end,
  chip = function()
    local p = get_probe_rs_project()
    return (p and cargo.chip(p)) or 'STM32F411CEUx'
  end,
  flashingConfig = {
    flashingEnabled = true,
    -- false: run straight after reset instead of halting in the vector table
    -- (__INTERRUPTS, which has no source line -> nvim-dap's noisy "Source
    -- missing, cannot jump to frame"). Breakpoints are armed before the core
    -- runs, so execution still stops at them.
    haltAfterReset = false,
  },
  coreConfigs = {
    {
      coreIndex = 0,
      -- probe-rs 0.31 renamed this from `programBinaryFile` to `programBinary`.
      -- The build is already done by the time `cwd` resolves, so this just
      -- points at the freshly-built ELF.
      programBinary = function()
        local p = get_probe_rs_project()
        return p and cargo.binary_path(p) or '${workspaceFolder}/target/debug/${workspaceFolderBasename}'
      end,
      -- Stream defmt/RTT logs into the DAP "Debug Console" during a debug
      -- session (probe-rs auto-detects the defmt format from the ELF).
      rttEnabled = true,
      -- Halt the debugger on a HardFault / panic instead of silently spinning.
      catchHardfault = true,
    },
  },
})
