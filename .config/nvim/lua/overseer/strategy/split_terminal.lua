-- Custom overseer strategy that runs the task in a horizontal split using
-- vim.fn.termopen(), giving a fully interactive terminal (keyboard input,
-- curses apps, etc.). The split stays open alongside other buffers.
local M = {}
M.__index = M

function M.new(_opts)
  return setmetatable({ job_id = nil, bufnr = nil }, M)
end

function M:start(task)
  vim.cmd 'enew'
  self.bufnr = vim.api.nvim_get_current_buf()
  self.job_id = vim.fn.termopen(task.cmd, {
    on_exit = function(_, code)
      task:on_exit(code)
    end,
  })
  -- termopen can mark the buffer as unlisted; force it into the tabline
  vim.bo[self.bufnr].buflisted = true
  -- bufhidden=hide keeps the buffer alive when its window is closed so the
  -- user can navigate back to it via the tabline
  vim.bo[self.bufnr].bufhidden = 'hide'
  -- Give it a recognisable name instead of the raw term:// URI
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(self.bufnr) then
      pcall(vim.api.nvim_buf_set_name, self.bufnr, task.name)
    end
  end)
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
  if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
  end
end

function M:get_bufnr()
  return self.bufnr
end

return M
