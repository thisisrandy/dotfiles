-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "v", "c" }, "jk", "<esc>")
vim.keymap.set("n", "<C-_>", "gcc")
vim.keymap.set("i", "<C-_>", "<C-o>gcc")
vim.keymap.set("v", "<C-_>", "gc")
vim.keymap.set("n", "<C-p>", "gcc")
