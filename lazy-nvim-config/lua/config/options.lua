-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.spell = true
vim.opt.dictionary = "/usr/share/dict/words"
vim.opt.virtualedit = "onemore"
vim.opt.list = false
vim.opt.listchars = "space:·,multispace:····+,tab:-￫,eol:¶,trail:~,extends:>,precedes:<,nbsp:⍽"
vim.g.netrw_browsex_viewer = "setsid xdg-open"
-- LazyVim sets this to unnamedplus, which we don't want to use due to perf
-- issues. See e.g. https://github.com/neovim/neovim/issues/11804 and also my
-- mappings using specific registers in keymaps.lua
vim.o.clipboard = ""
