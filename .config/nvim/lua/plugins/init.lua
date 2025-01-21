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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      animate = {
        duration = 10,
        easing = "quad",
        fps = 120,
      },
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
      indent = { enabled = true },
      input = { enabled = true, noautocmd = true, b = { completion = false } },
      notifier = { enabled = true, style = "compact", timeout = 5000 },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = false },
    },
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
      require("tiny-inline-diagnostic").setup {
        preset = "modern",
        options = {
          add_messages = true,
          softwrap = 30,
          multilines = {
            enabled = true,
            always_show = false,
          },
          enable_on_insert = false,
          overflow = {
            mode = wrap,
          },
          virt_texts = {
            priority = 2048,
          },
        },
      }
    end,
  },
}
