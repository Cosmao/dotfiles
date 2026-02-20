-- Custom overseer strategy that runs the task in a fullscreen floating
-- terminal. When the process exits the float closes automatically,
-- restoring the previous window layout.
local M = {}
M.__index = M

function M.new(_opts)
  return setmetatable({ job_id = nil, bufnr = nil, win = nil }, M)
end

function M:start(task)
  local buf = vim.api.nvim_create_buf(false, true)
  self.bufnr = buf

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = vim.o.columns,
    height = vim.o.lines - 2,
    row = 0,
    col = 0,
    style = 'minimal',
    border = 'none',
    zindex = 200,
  })
  self.win = win

  self.job_id = vim.fn.termopen(task.cmd, {
    on_exit = function(_, code)
      -- Close the float as soon as the process exits
      vim.schedule(function()
        if self.win and vim.api.nvim_win_is_valid(self.win) then
          vim.api.nvim_win_close(self.win, true)
          self.win = nil
        end
        if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
          vim.api.nvim_buf_delete(self.bufnr, { force = true })
          self.bufnr = nil
        end
      end)
      task:on_exit(code)
    end,
  })
  vim.cmd 'startinsert'
end

function M:stop()
  if self.job_id and self.job_id > 0 then
    vim.fn.jobstop(self.job_id)
    self.job_id = nil
  end
end

function M:reset()
  self:stop()
end

function M:dispose()
  self:stop()
  if self.win and vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
    self.win = nil
  end
  if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
    self.bufnr = nil
  end
end

function M:get_bufnr()
  return self.bufnr
end

return M
