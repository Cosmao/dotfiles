return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit" },
    --    lazy = false,
    --[[    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    }, ]]
    --
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
    --   dependencies = { "nvim-lua/plenary.nvim" },
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
    --[[dependencies = {
      "rcarriga/nvim-notify",
      "stevearc/dressing.nvim",
    },]]
    --
    config = function()
      require("overseer").setup {
        templates = {
          "builtin",
          "usr.java_build",
          "usr.java_run",
        },
      }
    end,
    --lazy = false,
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
    --dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
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
