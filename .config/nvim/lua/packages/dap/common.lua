local M = {}

function M.cargo_cwd(project)
  if not project.root or project.root == '.' then
    return vim.fn.getcwd()
  end
  return vim.fn.getcwd() .. '/' .. project.root
end

local function cargo_package_name(project)
  local toml = M.cargo_cwd(project) .. '/Cargo.toml'
  local f = io.open(toml, 'r')
  if f then
    for line in f:lines() do
      local name = line:match '^name%s*=%s*"([^"]+)"'
      if name then
        f:close()
        return name
      end
    end
    f:close()
  end
  return vim.fn.fnamemodify(M.cargo_cwd(project), ':t')
end

function M.binary_path(project)
  if project.binary then
    return project.binary
  end
  local cwd = M.cargo_cwd(project)
  local name = cargo_package_name(project)
  if project.target then
    return cwd .. '/target/' .. project.target .. '/debug/' .. name
  end
  return cwd .. '/target/debug/' .. name
end

return M
