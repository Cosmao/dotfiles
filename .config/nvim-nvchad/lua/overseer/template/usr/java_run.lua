return {
  name = "java run",
  builder = function()
    -- Full path to current file (see :help expand())
    local file = vim.fn.expand "%:p"
    return {
      cmd = { "java" },
      args = { file },
      components = {
        { "on_output_quickfix", open = true },
        -- { "on_complete_notify", statuses = { "SUCCESS" } },
        "default",
      },
    }
  end,
  condition = {
    filetype = { "java" },
  },
}
