local overseer = require 'overseer'
-- Shared resolvers (target/chip/binary derived from the crate's config files).
local common = require 'packages.dap.common'

local function project_name(project)
  if project.name then return project.name end
  if project.root and project.root ~= '.' then
    return vim.fn.fnamemodify(project.root, ':t')
  end
  return 'Rust'
end

local function cargo_cmd(project, args)
  local cmd = { 'cargo' }
  vim.list_extend(cmd, args)
  local target = common.target(project)
  if target then
    vim.list_extend(cmd, { '--target', target })
  end
  return cmd
end

local M = { type = 'cargo' }

function M.label(project)
  local label = 'Rust — ' .. project_name(project)
  local chip = common.chip(project)
  if chip then
    label = label .. '  [' .. chip .. ']'
  end
  return label
end

function M.dispatch(project)
  local label = project_name(project)
  local actions = {
    { name = 'Build', cmd = cargo_cmd(project, { 'build' }) },
    { name = 'Build Release', cmd = cargo_cmd(project, { 'build', '--release' }) },
  }
  local chip = common.chip(project)
  if chip then
    local binary = common.binary_path(project)
    vim.list_extend(actions, {
      { name = 'probe-rs: Download (flash only)', cmd = { 'probe-rs', 'download', '--chip', chip, binary } },
      {
        name = 'probe-rs: Run (flash + RTT)',
        cmd = { 'probe-rs', 'run', '--chip', chip, binary },
        -- This task runs until you stop it. Stopping sends SIGINT/SIGTERM (and
        -- SIGKILL if it's mid-flash), so treat those exit codes as a clean stop
        -- instead of a failure. Listing on_exit_set_status before 'default'
        -- overrides the alias's copy (resolve() keeps the first by name).
        components = {
          { 'on_exit_set_status', success_codes = { 130, 143, 137 } },
          'default',
        },
      },
      -- No manual DAP server action: nvim-dap (packages/dap/probe_rs.lua) spawns
      -- and tears down `probe-rs dap-server` per debug session automatically.
    })
  end

  local cwd = common.cargo_cwd(project)
  if not vim.uv.fs_stat(cwd) then
    vim.notify('Cargo: directory not found: ' .. cwd, vim.log.levels.ERROR)
    return
  end

  vim.ui.select(actions, {
    prompt = 'Action [' .. label .. ']:',
    format_item = function(a)
      return a.name
    end,
  }, function(action)
    if not action then
      return
    end
    local t = overseer.new_task {
      name = action.name .. ' [' .. label .. ']',
      cmd = action.cmd,
      cwd = cwd,
      components = action.components, -- nil falls back to the 'default' alias
    }
    t:start()
    overseer.open { enter = false }
  end)
end

return M
