" This is the portion of init.vim that is just mappings and autocmds, i.e.
" doesn't rely on any plugins. It ought to be sourced near the top of
" init.vim

" call plug#end() also executes the following lines, but since we might only
" be sourcing this file, execute them explicitly here
filetype plugin indent on
syntax on

set termguicolors
set number

" remap leader
let mapleader=" "

" remap escape
imap jk <Esc>
cmap jk <Esc>

" remap Y
map Y y$

" map to execute the current line
nmap <F6> :exec '!'.getline('.')

" turn down timeoutlen (defaults to 1000)
set timeoutlen=500

" Tabs
set softtabstop=2
set shiftwidth=2
set expandtab

" Open hsplit below current window
set splitbelow
" Open vsplit right of current window
set splitright

" Don't use two spaces after a period when joining lines or formatting
set nojoinspaces

" highlight cursor line in the active window only
augroup CursorLineOnlyInActiveWindow
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

" Remap window resizing. This is a little weird, since it isn't window
" placement-aware, but it'll do
nnoremap <C-S-Left> <Cmd>vertical resize -10<CR>
nnoremap <C-S-Right> <Cmd>vertical resize +10<CR>
nnoremap <C-S-Down> <Cmd>resize -5<CR>
nnoremap <C-S-Up> <Cmd>resize +5<CR>

" Search
set ignorecase
set smartcase

" Allows buffer switching without writing. Also for scratch.vim
set hidden

" autoread changed files
set autoread

" Shortcuts for copy/paste to clipboard
" noremap <Leader>y "+y
" noremap <Leader>p "+p
" Yank and paste with the system clipboard
set clipboard+=unnamedplus

" C-h - Find and replace
" <leader>/ - Clear highlighted search terms while preserving history
nnoremap <C-h> :%s/\v//g<left><left><left>
vnoremap <C-h> :s/\v//g<left><left><left>
nnoremap <silent> <leader>/ :nohlsearch<CR>
" actually, highlighting is never useful. just turn it off altogether. note
" there are some weird cases where highlighting still happens, so leave the
" <leader>/ binding in place just in case
set hls!

" move lines up and down with M-k/j (or up/down) from
" https://vim.fandom.com/wiki/Moving_lines_up_or_down#Mappings_to_move_lines,
" modified to use map-cmds and thus not change modes, which plays nicely with
" plugins like vim-airline that want to execute expensive autocmds on mode
" changes
nnoremap <M-j> <Cmd>m .+1<CR>==
nnoremap <M-k> <Cmd>m .-2<CR>==
inoremap <M-k> <Cmd>m .-2<CR><Cmd>norm ==<CR>
inoremap <M-j> <Cmd>m .+1<CR><Cmd>norm ==<CR>
vnoremap <M-j> <Cmd>call V_Move(0)<CR>
vnoremap <M-k> <Cmd>call V_Move(1)<CR>
nmap <M-Down> <M-j>
nmap <M-Up> <M-k>
imap <M-Down> <M-j>
imap <M-Up> <M-k>
vmap <M-Down> <M-j>
vmap <M-Up> <M-k>

" the following is a rather over-complicating-seeming way of replicating the
" following mappings without changing modes:
"
" vnoremap <A-j> :m '>+1<CR>gv=gv
" vnoremap <A-k> :m '<-2<CR>gv=gv
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

" rebind <Home> to ^ (first non-whitespace character)
nmap <Home> ^
vmap <Home> ^
imap <Home> <C-o>^

" make line wrapping nicer. off by default
set nowrap
set virtualedit=block,onemore
noremap <silent> <Leader>wr :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Wrap OFF"
    setlocal nowrap
    setlocal virtualedit=block,onemore
    silent! nunmap <buffer> k
    silent! nunmap <buffer> j
    silent! nunmap <buffer> <Up>
    silent! nunmap <buffer> <Down>
    silent! nunmap <buffer> <Home>
    silent! nunmap <buffer> <End>
    silent! iunmap <buffer> <Up>
    silent! iunmap <buffer> <Down>
    silent! iunmap <buffer> <Home>
    silent! iunmap <buffer> <End>
  else
    echo "Wrap ON"
    setlocal wrap linebreak nolist
    setlocal virtualedit=onemore
    setlocal display+=lastline
    noremap  <buffer> <silent> k gk
    noremap  <buffer> <silent> j gj
    noremap  <buffer> <silent> <Up>   gk
    noremap  <buffer> <silent> <Down> gj
    noremap  <buffer> <silent> <Home> g^
    noremap  <buffer> <silent> <End>  g<End>
    inoremap <buffer> <silent> <Up>   <C-o>gk
    inoremap <buffer> <silent> <Down> <C-o>gj
    inoremap <buffer> <silent> <Home> <C-o>g<Home>
    inoremap <buffer> <silent> <End>  <C-o>g<End>
  endif
endfunction

" make window navigation simpler
nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l

" on open terminal (:te), start in terminal mode
autocmd TermOpen * startinsert
" allow exit to normal mode with esc
:tnoremap <Esc> <C-\><C-n>

" always trim whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" save in insert mode
inoremap <C-s> <C-o>:w<CR>

" mappings to cut and paste into the "black hole register"
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

