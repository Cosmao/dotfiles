-- Shared resolvers for cargo/embedded projects. Single source of truth:
--   * compile target + probe-rs chip  <- <crate>/.cargo/config.toml
--   * package (binary) name            <- <crate>/Cargo.toml
-- A project in vim.g.projects only needs { type, name, root }; everything else
-- is derived here. Any field may still be set explicitly to override.
local M = {}

function M.cargo_cwd(project)
  if not project.root or project.root == '.' then
    return vim.fn.getcwd()
  end
  return vim.fn.getcwd() .. '/' .. project.root
end

-- Non-comment lines of <crate>/.cargo/config.toml (so a `--chip` or `target`
-- mentioned in a comment can't poison the parse).
local function config_lines(project)
  local f = io.open(M.cargo_cwd(project) .. '/.cargo/config.toml', 'r')
  if not f then
    return {}
  end
  local lines = {}
  for line in f:lines() do
    if not line:match '^%s*#' then
      lines[#lines + 1] = line
    end
  end
  f:close()
  return lines
end

-- Compile target triple: explicit override, else `[build] target` in config.toml.
function M.target(project)
  if project.target then
    return project.target
  end
  for _, line in ipairs(config_lines(project)) do
    local t = line:match '^%s*target%s*=%s*"([^"]+)"'
    if t then
      return t
    end
  end
  return nil
end

-- probe-rs chip: explicit override, else `--chip <X>` inside the config.toml
-- runner. Doubles as the "is this a flashable project?" predicate (nil = no).
function M.chip(project)
  if project.chip then
    return project.chip
  end
  for _, line in ipairs(config_lines(project)) do
    local runner = line:match 'runner%s*=%s*"([^"]+)"'
    if runner then
      return runner:match '%-%-chip[%s=]+([%w_]+)'
    end
  end
  return nil
end

-- Crate package name from Cargo.toml `[package] name`; dir basename as fallback.
function M.package_name(project)
  local f = io.open(M.cargo_cwd(project) .. '/Cargo.toml', 'r')
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

-- Absolute path to the built debug ELF.
function M.binary_path(project)
  if project.binary then
    return project.binary
  end
  local cwd = M.cargo_cwd(project)
  local name = M.package_name(project)
  local target = M.target(project)
  if target then
    return cwd .. '/target/' .. target .. '/debug/' .. name
  end
  return cwd .. '/target/debug/' .. name
end

return M
