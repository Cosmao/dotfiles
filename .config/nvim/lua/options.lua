require "nvchad.options"

-- add yours here!

vim.wo.number = true
vim.wo.relativenumber = true

require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--hidden",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
}

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
