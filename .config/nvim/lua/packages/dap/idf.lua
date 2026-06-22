local dap = require 'dap'

local function get_idf_project()
  local projects = vim.g.projects or {}
  for _, p in ipairs(projects) do
    if p.type == 'idf' then
      return p
    end
  end
  return nil
end

local function idf_project_dir(project)
  if project.root and project.root ~= '.' then
    return vim.fn.getcwd() .. '/' .. project.root
  end
  return vim.fn.getcwd()
end

local function idf_project_name(project_dir)
  local f = io.open(project_dir .. '/CMakeLists.txt', 'r')
  if f then
    for line in f:lines() do
      local name = line:match 'project%s*%(([^%)%s,]+)'
      if name then
        f:close()
        return name
      end
    end
    f:close()
  end
  return vim.fn.fnamemodify(project_dir, ':t')
end

-- Start via overseer: <leader>or → Project → OpenOCD (debug server)
dap.adapters.xtensa_gdb = {
  type = 'executable',
  command = 'gdb',
  args = { '--interpreter=dap' },
}

local idf_config = {
  type = 'xtensa_gdb',
  request = 'attach',
  name = 'ESP32 (OpenOCD)',
  target = 'extended-remote :3333',
  stopAtBeginningOfMainSubprogram = false,
  program = function()
    local p = get_idf_project()
    local dir = p and idf_project_dir(p) or vim.fn.getcwd()
    local name = idf_project_name(dir)
    local path = dir .. '/build/' .. name .. '.elf'
    vim.notify('DAP binary: ' .. path, vim.log.levels.INFO)
    return path
  end,
  cwd = function()
    local p = get_idf_project()
    return p and idf_project_dir(p) or vim.fn.getcwd()
  end,
}

dap.configurations.c = dap.configurations.c or {}
dap.configurations.cpp = dap.configurations.cpp or {}
table.insert(dap.configurations.c, idf_config)
table.insert(dap.configurations.cpp, idf_config)
