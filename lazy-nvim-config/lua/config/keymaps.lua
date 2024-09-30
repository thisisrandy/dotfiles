-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "c" }, "jk", "<esc>")
vim.keymap.set("n", "<c-h>", ":KittyNavigateLeft<cr>", { silent = true })
vim.keymap.set("n", "<c-j>", ":KittyNavigateDown<cr>", { silent = true })
vim.keymap.set("n", "<c-k>", ":KittyNavigateUp<cr>", { silent = true })
vim.keymap.set("n", "<c-l>", ":KittyNavigateRight<cr>", { silent = true })
vim.keymap.set("n", "<C-_>", "gcc", { desc = "Toggle line comment", remap = true })
vim.keymap.set("i", "<C-_>", "<C-o>gcc", { desc = "Toggle line comment", remap = true })
vim.keymap.set("v", "<C-_>", "gc", { desc = "Toggle line comments", remap = true })
