local utils = require 'utils'
vim.pack.add {
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = '0.1.x' },
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
}

require('telescope').setup {
  defaults = {
    preview = {
      treesitter = false,
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
local theme_file = vim.fn.stdpath 'data' .. '/colorscheme'

utils.set_keymaps {
  { 'n', '<leader>fh', builtin.help_tags, desc = '[S]earch [H]elp' },
  { 'n', '<leader>fk', builtin.keymaps, desc = '[S]earch [K]eymaps' },
  { 'n', '<leader>ff', builtin.find_files, desc = '[S]earch [F]iles' },
  { 'n', '<leader>fs', builtin.builtin, desc = '[S]earch [S]elect Telescope' },
  { { 'n', 'v' }, '<leader>fw', builtin.grep_string, desc = '[S]earch current [W]ord' },
  { 'n', '<leader>fg', builtin.live_grep, desc = '[S]earch by [G]rep' },
  { 'n', '<leader>fd', builtin.diagnostics, desc = '[S]earch [D]iagnostics' },
  { 'n', '<leader>fr', builtin.resume, desc = '[S]earch [R]esume' },
  { 'n', '<leader>f.', builtin.oldfiles, desc = '[S]earch Recent Files ("." for repeat)' },
  { 'n', '<leader><leader>', builtin.buffers, desc = '[ ] Find existing buffers' },
  {
    'n',
    '<leader>/',
    function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end,
    desc = '[/] Fuzzily search in current buffer',
  },
  {
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    desc = '[S]earch [/] in Open Files',
  },
  {
    'n',
    '<leader>sn',
    function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end,
    desc = '[S]earch [N]eovim files',
  },
  {
    'n',
    '<leader>ft',
    function()
      builtin.colorscheme {
        enable_preview = true,
        attach_mappings = function(prompt_bufnr, _)
          local actions = require 'telescope.actions'
          local action_state = require 'telescope.actions.state'
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              vim.cmd.colorscheme(selection.value)
              local f = io.open(theme_file, 'w')
              if f then
                f:write(selection.value)
                f:close()
              end
            end
          end)
          return true
        end,
      }
    end,
    desc = '[F]ind [T]heme',
  },
}
