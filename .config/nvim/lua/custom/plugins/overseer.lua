return {
  'stevearc/overseer.nvim',
  opts = {},
  config = function()
    local overseer = require 'overseer'
    overseer.setup {}

    -- NOTE: ESP-IDF tasks, only registered when an sdkconfig is present in
    -- the project root (indicates an ESP-IDF project)
    local idf_tasks = {
      {
        name = 'ESP-IDF: Full Clean',
        cmd = { 'idf.py', 'fullclean' },
      },
      {
        name = 'ESP-IDF: Build',
        cmd = { 'idf.py', 'build' },
      },
      {
        name = 'ESP-IDF: Flash',
        cmd = { 'idf.py', 'flash' },
      },
      {
        -- NOTE: Runs in a terminal buffer since monitor is interactive
        name = 'ESP-IDF: Flash & Monitor',
        cmd = { 'idf.py', 'flash', 'monitor' },
        interactive = true,
      },
      {
        -- NOTE: Runs in a terminal buffer since menuconfig is a curses TUI
        name = 'ESP-IDF: Menuconfig',
        cmd = { 'idf.py', 'menuconfig' },
        interactive = true,
      },
    }

    for _, task in ipairs(idf_tasks) do
      local t = task
      overseer.register_template {
        name = t.name,
        condition = {
          callback = function()
            return vim.fn.filereadable(vim.fn.getcwd() .. '/sdkconfig') == 1
              or vim.fn.filereadable(vim.fn.getcwd() .. '/sdkconfig.defaults') == 1
          end,
        },
        builder = function()
          return {
            cmd = t.cmd,
            strategy = t.interactive and 'terminal' or 'jobstart',
          }
        end,
      }
    end
  end,

  keys = {
    { '<leader>or', '<cmd>OverseerRun<CR>', desc = '[O]verseer [R]un task' },
    { '<leader>ot', '<cmd>OverseerToggle<CR>', desc = '[O]verseer [T]oggle panel' },
  },
}
