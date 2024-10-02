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
vim.keymap.set("i", "<C-v>", "<C-o>P", { desc = "Paste from the keyboard in insert mode", noremap = true })
vim.keymap.set("n", "<F6>", ":exec '!'.getline('.')<CR>", { desc = "Execute the current line as a shell command" })
vim.keymap.set("n", "<F7>", ":exec getline('.')<CR>", { desc = "Execute the current line as a vim command" })
vim.keymap.set({ "n", "v" }, "<leader>o", ":nohl<CR>", { desc = "Turn highlighting [o]ff", silent = true })
vim.keymap.set({ "n", "v" }, "?", "?\\v", { desc = "Search backwards using very magic mode" })
vim.keymap.set({ "n", "v" }, "/", "/\\v", { desc = "Search using very magic mode" })
vim.keymap.set("n", "<leader>h", ":%s/\\v//g<left><left><left>", { desc = "Search/replace in the current buffer" })
vim.keymap.set("v", "<leader>h", ":s/\\v//g<left><left><left>", { desc = "Search/replace in the current selection" })
vim.keymap.set("n", "gh", "K", { desc = "Hover (synonym for K)", remap = true })
vim.keymap.set("n", ";", "<leader>,", { desc = "Switch buffers", remap = true })
vim.keymap.set("n", "<C-p>", "<leader>ff", { desc = "Find files (Root Dir)", remap = true })
vim.keymap.set("n", "<F2>", "<leader>cr", { desc = "Rename", remap = true })
-- Note that neither of the following account for special regex chars in any
-- way. Copied text has the potential to be a malformed expression
vim.keymap.set(
  "n",
  "<leader>su",
  '"zyiw<leader>sg<c-r>z',
  { desc = "Grep for word [u]nder cursor (Root Dir)", remap = true }
)
vim.keymap.set(
  "n",
  "<leader>sU",
  '"zyiw<leader>sG<c-r>z',
  { desc = "Grep for word [U]nder cursor (cwd)", remap = true }
)
vim.keymap.set(
  "v",
  "<leader>su",
  '"zy<leader>sg<c-r>z',
  { desc = "Grep for highlighted word ([u]nder cursor) (Root Dir)", remap = true }
)
vim.keymap.set(
  "v",
  "<leader>sU",
  '"zy<leader>sG<c-r>z',
  { desc = "Grep for highlighted word ([U]nder cursor) (cwd)", remap = true }
)

-- move lines up and down with M-k/j (or up/down) from
-- https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines,
-- modified to use map-cmds and thus not change modes, which plays nicely with
-- plugins like vim-airline that want to execute expensive autocmds on mode
-- changes. see the discussion at
-- https://github.com/vim-airline/vim-airline/issues/2440
vim.keymap.set("i", "<M-k>", "<Cmd>m .-2<CR><Cmd>norm ==<CR>", { desc = "Move the current line up" })
vim.keymap.set("i", "<M-j>", "<Cmd>m .+1<CR><Cmd>norm ==<CR>", { desc = "Move the current line down" })
vim.keymap.set("v", "<M-k>", "<Cmd>call V_Move(1)<CR>", { desc = "Move the selected lines up" })
vim.keymap.set("v", "<M-j>", "<Cmd>call V_Move(0)<CR>", { desc = "Move the selected lines down" })
vim.cmd([[
function! V_Move(up)
  let list  = [ line('.'), line('v') ]
  let upper = min(list)
  let lower = max(list)
  let cursor_above = line('.') < line('v')
  let took_action = 0

  " movement and reselection
  if a:up
    " don't attempt if we're already at the top
    if upper > 1
      let took_action = 1
      exe upper .. ',' .. lower .. 'm ' .. (upper-2)
      if cursor_above
        exe "norm! " .. (lower-upper) .. "kok"
      else
        exe "norm! ok"
      endif
    endif
  else
    " don't attempt if we're already at the bottom
    if lower < line('$')
      let took_action = 1
      exe upper .. ',' .. lower .. 'm ' .. (lower+1)
      if cursor_above
        " 0 means move beginning of line, not repeat 0 times, so we need a
        " guard here
        if lower-upper > 1
          exe "norm! o" .. (lower-upper-1) .. "k"
        endif
      else
        exe "norm! oj"
      endif
    endif
  endif

  " formatting and reselection
  if took_action
    exe "norm! =V"
    " after formatting, we always end up at the top of the selection. it only
    " remains to select the rest of it, if any. as above, guard against 0, which
    " has a different meaning
    if lower-upper
      exe "norm! " .. (lower-upper) .. "j"
    endif
  endif
endfu
]])
