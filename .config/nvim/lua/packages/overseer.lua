local utils = require 'utils'
vim.pack.add { 'https://github.com/stevearc/overseer.nvim' }

local overseer = require 'overseer'
overseer.setup {
  form = { border = 'rounded' },
}

local function find_idf_projects(root)
  local cmd = string.format(
    "find '%s' -path '*/managed_components' -prune -o -path '*/build' -prune -o"
      .. " -name 'CMakeLists.txt' -path '*/main/CMakeLists.txt' -print",
    root
  )
  local output = vim.fn.system(cmd)
  local projects = {}
  local seen = {}
  for match in output:gmatch '[^\n]+' do
    local dir = vim.fn.fnamemodify(match, ':h:h')
    if vim.fn.fnamemodify(dir, ':t') ~= 'test' and not seen[dir] then
      seen[dir] = true
      table.insert(projects, dir)
    end
  end
  return projects
end

local idf_tasks = {
  { name = 'Fullclean', cmd = { 'idf.py', 'fullclean' } },
  { name = 'Build', cmd = { 'idf.py', 'build' } },
  { name = 'Flash', cmd = { 'idf.py', 'flash' } },
  { name = 'Flash & Monitor', cmd = { 'idf.py', 'flash', 'monitor' } },
  {
    name = 'Test Flash & Monitor',
    cmd = { 'sh', '-c', 'cp sdkconfig test/sdkconfig && idf.py -C test flash monitor' },
  },
  { name = 'Custom...', custom = true },
}

local function pick_idf_command(project)
  local short = vim.fn.fnamemodify(project, ':t')
  vim.ui.select(idf_tasks, {
    prompt = 'ESP-IDF [' .. short .. ']:',
    format_item = function(t)
      return t.name
    end,
  }, function(task)
    if not task then
      return
    end
    if task.custom then
      vim.ui.input({ prompt = 'idf.py args: ' }, function(input)
        if not input then
          return
        end
        local t = overseer.new_task {
          name = 'ESP-IDF: idf.py ' .. input .. ' [' .. short .. ']',
          cmd = vim.list_extend({ 'idf.py' }, vim.split(input, ' ')),
          cwd = project,
        }
        t:start()
        overseer.open { enter = false }
      end)
    else
      local t = overseer.new_task {
        name = 'ESP-IDF: ' .. task.name .. ' [' .. short .. ']',
        cmd = task.cmd,
        cwd = project,
        strategy = 'jobstart',
      }
      t:start()
      overseer.open { enter = false }
    end
  end)
end

local function run_idf_task()
  local git_root = vim.trim(vim.fn.system 'git rev-parse --show-toplevel')
  if vim.v.shell_error ~= 0 then
    git_root = vim.fn.getcwd()
  end
  local projects = find_idf_projects(git_root)
  if #projects == 0 then
    vim.notify('No ESP-IDF projects found under ' .. git_root, vim.log.levels.WARN)
    return
  end
  if #projects == 1 then
    pick_idf_command(projects[1])
  else
    vim.ui.select(projects, {
      prompt = 'ESP-IDF project:',
      format_item = function(p)
        return vim.fn.fnamemodify(p, ':t')
      end,
    }, function(project)
      if project then
        pick_idf_command(project)
      end
    end)
  end
end

overseer.register_template {
  name = 'ESP-IDF',
  builder = function()
    vim.schedule(run_idf_task)
    return {
      cmd = { 'true' },
      components = { { 'on_complete_dispose', timeout = 1 } },
    }
  end,
}

utils.set_keymaps {
  { 'n', '<leader>or', '<cmd>OverseerRun<CR>', desc = '[O]verseer [R]un task' },
  { 'n', '<leader>ot', '<cmd>OverseerToggle<CR>', desc = '[O]verseer [T]oggle panel' },
}
