return {
  'stevearc/overseer.nvim',
  opts = {},
  config = function()
    local overseer = require 'overseer'
    overseer.setup {
      form = { border = 'rounded' },
    }

    local idf_tasks = {
      { name = 'ESP-IDF: Fullclean', cmd = { 'idf.py', 'fullclean' } },
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
        table.insert(templates, {
          name = 'ESP-IDF: Custom',
          params = {
            args = { type = 'string', name = 'Arguments', order = 1 },
          },
          builder = function(params)
            return {
              cmd = vim.list_extend({ 'idf.py' }, vim.split(params.args, ' ')),
            }
          end,
        })
        cb(templates)
      end,
    }

    local ok, rsync_hosts = pcall(require, 'custom.plugins.rsync_hosts')
    if not ok then
      rsync_hosts = {}
    end

    overseer.register_template {
      name = 'Rsync',
      generator = function(opts, cb)
        local ignore_file = vim.fn.getcwd() .. '/.rsync_ignore'
        if vim.fn.filereadable(ignore_file) == 0 then
          return cb {}
        end
        local templates = {}
        for _, host in ipairs(rsync_hosts) do
          local h = host
          table.insert(templates, {
            name = h.name,
            builder = function()
              return {
                cmd = { 'rsync', '-avz', '--exclude-from=.rsync_ignore', './', h.dest },
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
