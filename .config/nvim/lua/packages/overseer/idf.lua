local overseer = require 'overseer'

local function project_name(project)
  if project.name then return project.name end
  if project.root and project.root ~= '.' then
    return vim.fn.fnamemodify(project.root, ':t')
  end
  return 'ESP-IDF'
end

local idf_actions = {
  { name = 'Fullclean', cmd = { 'idf.py', 'fullclean' } },
  { name = 'Build', cmd = { 'idf.py', 'build' } },
  { name = 'Flash', cmd = { 'idf.py', 'flash' } },
  { name = 'Flash & Monitor', cmd = { 'idf.py', 'flash', 'monitor' } },
  { name = 'OpenOCD (debug server)', cmd = { 'idf.py', 'openocd' } },
  {
    name = 'Test Flash & Monitor',
    cmd = { 'sh', '-c', 'cp sdkconfig test/sdkconfig && idf.py -C test flash monitor' },
  },
  { name = 'Custom...', custom = true },
}

local M = { type = 'idf' }

function M.label(project)
  return 'ESP-IDF — ' .. project_name(project)
end

local function open_picker(project)
  local project_dir = (project.root and project.root ~= '.')
    and (vim.fn.getcwd() .. '/' .. project.root)
    or vim.fn.getcwd()
  local label = project_name(project)

  vim.ui.select(idf_actions, {
    prompt = 'ESP-IDF [' .. label .. ']:',
    format_item = function(a)
      return a.name
    end,
  }, function(action)
    if not action then
      return
    end
    if action.custom then
      vim.ui.input({ prompt = 'idf.py args: ' }, function(input)
        if not input then
          return
        end
        local t = overseer.new_task {
          name = 'ESP-IDF: idf.py ' .. input .. ' [' .. label .. ']',
          cmd = vim.list_extend({ 'idf.py' }, vim.split(input, ' ')),
          cwd = project_dir,
        }
        t:start()
        overseer.open { enter = false }
      end)
    else
      local t = overseer.new_task {
        name = 'ESP-IDF: ' .. action.name .. ' [' .. label .. ']',
        cmd = action.cmd,
        cwd = project_dir,
        strategy = 'jobstart',
      }
      t:start()
      overseer.open { enter = false }
    end
  end)
end

function M.dispatch(project)
  if vim.env.IDF_PATH and vim.env.IDF_PATH ~= '' then
    open_picker(project)
    return
  end

  vim.notify('Sourcing ESP-IDF...', vim.log.levels.INFO)
  vim.system(
    { 'sh', '-c', '. $HOME/work/esp/esp-idf/export.sh && env' },
    { text = true },
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify('ESP-IDF not found — source export.sh manually', vim.log.levels.ERROR)
          return
        end
        for line in result.stdout:gmatch '[^\n]+' do
          local key, val = line:match '^([^=]+)=(.*)'
          if key then vim.env[key] = val end
        end
        if not vim.env.IDF_PATH or vim.env.IDF_PATH == '' then
          vim.notify('ESP-IDF not sourced — source export.sh manually', vim.log.levels.ERROR)
          return
        end
        open_picker(project)
      end)
    end
  )
end

return M
