return {
  'stevearc/overseer.nvim',
  opts = {},
  config = function()
    local overseer = require 'overseer'
    overseer.setup {}

    -- NOTE: Tasks only appear when sdkconfig or sdkconfig.defaults is present
    -- in cwd, indicating an ESP-IDF project
    -- NOTE: Tasks only appear when sdkconfig or sdkconfig.defaults is present
    -- in cwd, indicating an ESP-IDF project
    local idf_tasks = {
      { name = 'ESP-IDF: Full Clean', cmd = { 'idf.py', 'fullclean' } },
      { name = 'ESP-IDF: Build', cmd = { 'idf.py', 'build' } },
      { name = 'ESP-IDF: Flash', cmd = { 'idf.py', 'flash' } },
      { name = 'ESP-IDF: Flash & Monitor', cmd = { 'idf.py', 'flash', 'monitor' } },
      -- NOTE: Menuconfig uses split_terminal to open in the current window as
      -- a proper interactive terminal since it is a curses TUI
      {
        name = 'ESP-IDF: Menuconfig',
        cmd = { 'idf.py', 'menuconfig' },
        menuconfig = true,
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
            strategy = t.menuconfig and 'split_terminal' or 'jobstart',
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
