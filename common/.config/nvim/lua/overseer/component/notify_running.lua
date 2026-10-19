local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

return {
  desc = 'Spinner notification while task runs, updates on completion',
  constructor = function()
    return {
      _id = nil,
      _done = false,
      on_start = function(self, task)
        self._id = 'overseer_' .. tostring(task.id)
        self._done = false
        vim.notify(task.name, vim.log.levels.INFO, {
          id = self._id,
          title = 'Running',
          timeout = false,
          opts = function(notif)
            if not self._done then
              notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end
          end,
        })
      end,
      on_complete = function(self, task, status)
        self._done = true
        local ok = status == require('overseer').STATUS.SUCCESS
        vim.notify(task.name, ok and vim.log.levels.INFO or vim.log.levels.ERROR, {
          id = self._id,
          title = ok and 'Done' or 'Failed',
          icon = ok and '✓' or '✗',
          timeout = 3000,
        })
      end,
    }
  end,
}
