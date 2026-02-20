return {
  'stevearc/overseer.nvim',
  opts = {},
  config = function()
    local overseer = require 'overseer'
    overseer.setup {}

    local idf_tasks = {
      { name = 'ESP-IDF: Full Clean', cmd = { 'idf.py', 'fullclean' } },
      { name = 'ESP-IDF: Build', cmd = { 'idf.py', 'build' } },
      { name = 'ESP-IDF: Flash', cmd = { 'idf.py', 'flash' } },
      { name = 'ESP-IDF: Flash & Monitor', cmd = { 'idf.py', 'flash', 'monitor' } },
      -- NOTE: Menuconfig uses split_terminal which opens a fullscreen floating
      -- terminal; the float auto-closes when menuconfig exits
      {
        name = 'ESP-IDF: Menuconfig',
        cmd = { 'idf.py', 'menuconfig' },
        menuconfig = true,
      },
    }

    -- Use a generator so the check runs each time OverseerRun is opened,
    -- returning no tasks when $IDF_PATH is not set
    overseer.register_template {
      name = 'ESP-IDF',
      generator = function(opts, cb)
        if not vim.env.IDF_PATH then
          return cb {}
        end
        local templates = {}
        for _, task in ipairs(idf_tasks) do
          local t = task
          table.insert(templates, {
            name = t.name,
            builder = function()
              return {
                cmd = t.cmd,
                strategy = t.menuconfig and 'split_terminal' or 'jobstart',
              }
            end,
          })
        end
        cb(templates)
      end,
    }
  end,

  keys = {
    { '<leader>or', '<cmd>OverseerRun<CR>', desc = '[O]verseer [R]un task' },
    { '<leader>ot', '<cmd>OverseerToggle<CR>', desc = '[O]verseer [T]oggle panel' },
  },
}
