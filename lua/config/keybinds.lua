vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

-- Insert/Visual/Command mode -> Normal
vim.keymap.set("i", "²", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("v", "²", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("c", "²", "<Esc>", { noremap = true, silent = true })

