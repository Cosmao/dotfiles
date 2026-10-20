local utils = require 'utils'
vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    local lsp_format_opt
    if disable_filetypes[vim.bo[bufnr].filetype] then
      lsp_format_opt = 'never'
    else
      lsp_format_opt = 'fallback'
    end
    return {
      timeout_ms = 500,
      lsp_format = lsp_format_opt,
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'black' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
  },
}

utils.set_keymaps {
  {
    '',
    '<leader>bf',
    function()
      require('conform').format { async = true, lsp_format = 'fallback' }
    end,
    desc = '[F]ormat buffer',
  },
}
