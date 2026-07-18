-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.spell = true
vim.opt.dictionary = "/usr/share/dict/words"
vim.opt.virtualedit = "onemore"
vim.opt.list = false
vim.opt.listchars = "space:·,multispace:····+,tab:-￫,eol:¶,trail:~,extends:>,precedes:<,nbsp:⍽"
vim.g.netrw_browsex_viewer = "setsid xdg-open"
-- This is the solution to my system clipboard window focus-related woes. If we
-- ask the terminal for the clipboard instead of using an external program (see
-- :h clipboard-osc52) it doesn't make the UI flash. Note that some terminals
-- block reading the clipboard by default as it's a security concern. I've
-- configured kitty to allow all reads without asking, which is the only way to
-- have a nice experience with vim
vim.g.clipboard = "osc52"
