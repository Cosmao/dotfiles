return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit" },
    config = function()
      require("telescope").load_extension "lazygit"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },

  {
    { "xiyaowong/transparent.nvim", lazy = false },
  },

  {
    -- TODO: See if I can make it lazy load somehow, seems iffy
    "folke/todo-comments.nvim",
    lazy = false,
    opts = {},
  },

  {
    "rcarriga/nvim-notify",
    -- dependencies = {},
    config = function()
      -- require("telescope").load_extension "notify"
      -- require("telescope").extensions.notify.notify()
      require("notify").setup {
        background_colour = "#000000",
      }
    end,
  },

  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup {
        templates = {
          "builtin",
          "usr.java_build",
          "usr.java_run",
        },
      }
    end,
    cmd = { "OverseerToggle", "OverseerRun" },
  },

  {
    "stevearc/dressing.nvim",
    opts = {},
    config = function()
      require("dressing").setup {}
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {},
    config = function()
      require("render-markdown").setup {}
    end,
    ft = { "markdown" },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup {}
    end,
  },
}
