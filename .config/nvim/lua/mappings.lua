require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

--LazyGit
map("n", "<leader>gl", function()
  Snacks.lazygit()
end, { desc = "Lazygit" })

--TodoTelescope
map("n", "<leader>ft", "<cmd> TodoTelescope <cr>", { desc = "TodoTelescope" })
map("n", "<leader>fq", "<cmd> TodoQuickFix <cr>", { desc = "TodoQuickFix" })

--Overseer
-- map("n", "<leader>oo", "<cmd> OverseerToggle left<cr>", { desc = "Toggle Overseer" })
map("n", "<leader><S-o>", "<cmd> OverseerToggle left<cr>", { desc = "Toggle Overseer" })
map("n", "<leader>or", "<cmd> OverseerRun <cr>", { desc = "Overseer Run" })

--notify
map("n", "<leader>fn", "<cmd> Telescope notify <cr>", { desc = "Telescope Notify" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
