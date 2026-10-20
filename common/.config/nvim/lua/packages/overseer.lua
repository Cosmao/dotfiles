local utils = require 'utils'
vim.pack.add { 'https://github.com/stevearc/overseer.nvim' }

local overseer = require 'overseer'
overseer.setup {
  form = { border = 'rounded' },
  component_aliases = {
    default = {
      'on_exit_set_status',
      'notify_running',
      { 'on_complete_dispose', require_view = { 'SUCCESS', 'FAILURE' } },
    },
  },
}

local dispatchers = {}
for _, mod in ipairs {
  require 'packages.overseer.cargo',
  require 'packages.overseer.idf',
} do
  dispatchers[mod.type] = mod
end

local function run_project_picker()
  local projects = vim.g.projects
  if not projects or #projects == 0 then
    return
  end

  local function dispatch(project)
    local d = dispatchers[project.type]
    if d then
      d.dispatch(project)
    end
  end

  if #projects == 1 then
    dispatch(projects[1])
    return
  end

  vim.ui.select(projects, {
    prompt = 'Project:',
    format_item = function(p)
      local d = dispatchers[p.type]
      return d and d.label(p) or p.type
    end,
  }, function(project)
    if project then
      dispatch(project)
    end
  end)
end

utils.set_keymaps {
  { 'n', '<leader>or', function()
    if vim.g.projects and #vim.g.projects > 0 then
      run_project_picker()
    else
      vim.cmd 'OverseerRun'
    end
  end, desc = '[O]verseer [R]un task' },
  { 'n', '<leader>ot', '<cmd>OverseerToggle<CR>', desc = '[O]verseer [T]oggle panel' },
}
