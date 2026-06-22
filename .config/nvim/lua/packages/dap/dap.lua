local utils = require 'utils'
vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
}

local dap = require 'dap'
local dapui = require 'dapui'

vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#888888' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '●', texthl = 'DapBreakpointRejected', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', numhl = '' })

require 'packages.dap.rust'
require 'packages.dap.probe_rs'

dapui.setup()

dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

utils.set_keymaps {
  { 'n', '<leader>db', dap.toggle_breakpoint, desc = '[D]ap toggle [B]reakpoint' },
  { 'n', '<leader>dc', dap.continue, desc = '[D]ap [C]ontinue' },
  { 'n', '<leader>di', dap.step_into, desc = '[D]ap step [I]nto' },
  { 'n', '<leader>do', dap.step_over, desc = '[D]ap step [O]ver' },
  { 'n', '<leader>dO', dap.step_out, desc = '[D]ap step [O]ut' },
  { 'n', '<leader>dt', dapui.toggle, desc = '[D]ap [T]oggle UI' },
  { 'n', '<leader>dx', dap.terminate, desc = '[D]ap [X] terminate' },
}
