local overseer = require 'overseer'

local function project_name(project)
  if project.name then return project.name end
  if project.root and project.root ~= '.' then
    return vim.fn.fnamemodify(project.root, ':t')
  end
  return 'Rust'
end

local function cargo_cwd(project)
  if not project.root or project.root == '.' then
    return vim.fn.getcwd()
  end
  return vim.fn.getcwd() .. '/' .. project.root
end

local function cargo_cmd(project, args)
  local cmd = { 'cargo' }
  vim.list_extend(cmd, args)
  if project.target then
    vim.list_extend(cmd, { '--target', project.target })
  end
  return cmd
end

local function binary_path(project)
  if project.binary then
    return project.binary
  end
  local cwd = cargo_cwd(project)
  local name = vim.fn.fnamemodify(cwd, ':t')
  if project.target then
    return cwd .. '/target/' .. project.target .. '/debug/' .. name
  end
  return cwd .. '/target/debug/' .. name
end

local M = { type = 'cargo' }

function M.label(project)
  local label = 'Rust — ' .. project_name(project)
  if project.chip then
    label = label .. '  [' .. project.chip .. ']'
  end
  return label
end

function M.dispatch(project)
  local label = project_name(project)
  local actions = {
    { name = 'Build', cmd = cargo_cmd(project, { 'build' }) },
    { name = 'Build Release', cmd = cargo_cmd(project, { 'build', '--release' }) },
  }
  if project.chip then
    vim.list_extend(actions, {
      { name = 'probe-rs: Download (flash only)', cmd = { 'probe-rs', 'download', '--chip', project.chip, binary_path(project) } },
      { name = 'probe-rs: Run (flash + RTT)', cmd = { 'probe-rs', 'run', '--chip', project.chip, binary_path(project) } },
      { name = 'probe-rs: DAP server', cmd = { 'probe-rs', 'dap-server', '--port', '50000' } },
    })
  end

  local cwd = cargo_cwd(project)
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
    }
    t:start()
    overseer.open { enter = false }
  end)
end

return M
