-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

local cursor_line_only_in_active_window = augroup("CursorLineOnlyInActiveWindow")
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  group = cursor_line_only_in_active_window,
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = cursor_line_only_in_active_window,
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- kitty-scrollback gets confused if I try to start insert on term open, hence
-- the guard
if vim.env.KITTY_SCROLLBACK_NVIM ~= "true" then
  local term_insert = augroup("TermInsert")
  vim.api.nvim_create_autocmd("TermOpen", {
    group = term_insert,
    callback = function()
      vim.cmd.startinsert()
    end,
  })
end
