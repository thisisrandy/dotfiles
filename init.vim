""" Fresh installation notes
" remember to install vim-plug and run :PlugInstall
" this file is broken until plugins installed
" :so % to source it
" :checkhealth to insure plugins are working
"
" ripgrep (rg) must be installed for denite
" > sudo apt-get install ripgrep
"
" eslint and prettier-eslint must be installed for javascript per project
" > npm install --save-dev eslint
" > ./node_modules/.bin/eslint --init
" > npm install --save-dev prettier-eslint
"
" In order for floating messages to work in coc.nvim, neovim must
" be built from source (at time of writing, may change).
" > git clone https://github.com/neovim/neovim.git
" > make CMAKE_BUILD_TYPE=RelWithDebInfo
" > sudo make install
"
" neovim sometimes can't find a clipboard provider for unknown reasons.
" The solution seems to be manually installing one, e.g.
" > sudo apt-get install xclip
" (for sharing the system clipboard)
"
" :ConInstall to install language extensions
" Extensions: coc-json, coc-eslint, coc-tsserver, coc-snippets
" :CocConfig to open config file, then add
" {
"   "prettier.eslintIntegration": true
" }
"
" coc needs node (v12.x, obviously this will go out of date at some point)
" > sudo apt-get install curl
" > curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
" > sudo apt-get install -y nodejs
"
" tagbar requires universal-ctags
" > sudo apt-get install universal-ctags

""" Plug
call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'jnurmine/Zenburn'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'mtth/scratch.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'shougo/denite.nvim'
Plug 'easymotion/vim-easymotion'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-dadbod'
Plug 'majutsushi/tagbar'
Plug 'rstacruz/vim-hyperstyle'
Plug 'cohama/lexima.vim'
Plug 'wesQ3/vim-windowswap'
Plug 'jremmen/vim-ripgrep'

" this is probably useful for some languages, but unclear if it really
" supports nodejs. turning off for now
" Plug 'idanarye/vim-vebugger'
" Plug 'Shougo/vimproc.vim', {'do' : 'make'} " required for vim-debugger

" this doesn't currently work in neovim due to lack of netbeans support
" Plug 'sidorares/node-vim-debugger'
" Plug 'lrvick/Conque-Shell' " required for node-vim-debugger

call plug#end()

" call plug#end() executes this already
" filetype plugin indent on
" syntax on

" Appearance - dracula and zenburn both nice, at least for python
" colorscheme dracula
colorscheme zenburn
set number

" remap leader
let mapleader=" "

" remap escape and single command
imap ii <Esc>
vmap ii <Esc>
cmap ii <Esc>
imap uu <C-o>

" turn down timeoutlen (defaults to 1000)
set timeoutlen=500

" Tabs
set softtabstop=2
set shiftwidth=2
set expandtab

" Search
set ignorecase
set smartcase

" Allows buffer switching without writing. Also for scratch.vim
set hidden

" Shortcuts for copy/paste to clipboard
" noremap <Leader>y "+y
" noremap <Leader>p "+p
" Yank and paste with the system clipboard
set clipboard+=unnamedplus

" <leader>h - Find and replace
" <leader>/ - Clear highlighted search terms while preserving history
nmap <leader>h :%s///<left><left>
vmap <leader>h :s///<left><left>
nmap <silent> <leader>/ :nohlsearch<CR>

" move lines up and down with M-k/j (or up/down)
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv
nmap <M-Down> <M-j>
nmap <M-Up> <M-k>
imap <M-Down> <M-j>
imap <M-Up> <M-k>
vmap <M-Down> <M-j>
vmap <M-Up> <M-k>

" rebind <Home> to ^ (first non-whitespace character). unfortunately, this
" breaks in insert mode, as ^ counts as an input character
nmap <Home> ^
vmap <Home> ^

" make line wrapping nicer. off by default
set nowrap
set virtualedit=block,onemore
noremap <silent> <Leader>wr :call ToggleWrap()<CR>
function ToggleWrap()
  if &wrap
    echo "Wrap OFF"
    setlocal nowrap
    setlocal virtualedit=block,onemore
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

" made window navigation simpler
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l

" on open terminal (:te), start in terminal mode
autocmd TermOpen * startinsert

" always trim whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

""" NERDTree
map <C-n> :NERDTreeToggle<CR>
nmap <C-f> :NERDTreeFind<CR>

" This opens with file
" autocmd vimenter * NERDTree
" This opens without file
" let NERDTreeShowHidden=1
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" quit if last window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""" vim-airline
" remember to install powerline fonts
" https://powerline.readthedocs.io/en/latest/installation/linux.html#fonts-installation
let g:airline_powerline_fonts = 1

""" NERDcommenter

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" " Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a
" region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

""" coc.nvim

" correct comment highlighting for config file
autocmd FileType json syntax match Comment +\/\/.\+$+

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? "\<C-n>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use tab for trigger completion, completion confirm, snippet expand and jump like VSCode.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-diagnostic-next)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
nmap <silent> ge <Plug>(coc-diagnostic-next-error)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Whole buffer
command! -nargs=0 Prettier :CocCommand prettier.formatFile
" Alternate whole buffer format if prettier not available
nmap <leader>b  <Plug>(coc-format)
" Format on save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html Prettier
autocmd BufWritePre *.py :call CocAction('format')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Show commands
nnoremap <silent> <leader>c  :<C-u>CocList commands<cr>

""" Denite setup
" Use ripgrep for searching current directory for files
" By default, ripgrep will respect rules in .gitignore
"   --files: Print each file that would be searched (but don't search)
"   --glob:  Include or exclues files for searching that match the given glob
"            (aka ignore .git files)
"
call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])

" Use ripgrep in place of "grep"
call denite#custom#var('grep', 'command', ['rg'])

" Custom options for ripgrep
"   --vimgrep:  Show results with every match on it's own line
"   --hidden:   Search hidden directories and files
"   --heading:  Show the file name above clusters of matches from each file
"   --S:        Search case insensitively if the pattern is all lowercase
call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

" Recommended defaults for ripgrep via Denite docs
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Remove date from buffer list
call denite#custom#var('buffer', 'date_format', '')

" Open file commands
" TODO: this doesn't really seem to work...
call denite#custom#map('insert,normal', "<C-t>", '<denite:do_action:tabopen>')
call denite#custom#map('insert,normal', "<C-v>", '<denite:do_action:vsplit>')
call denite#custom#map('insert,normal', "<C-h>", '<denite:do_action:split>')

" ;         - Browser currently open buffers
" <leader>t - Browse list of files in current directory
" <leader>g - Search current directory for occurences of given term and close window if no results
" <leader>u - Search current directory for occurences of word under cursor
nmap ; :Denite buffer<CR>
nmap <leader>t :DeniteProjectDir file/rec<CR>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>u :<C-u>DeniteCursorWord grep:.<CR>

" Define mappings while in 'filter' mode
"   <C-o>         - Switch to normal mode inside of search results (fuzzy
"   matching)
"   <Esc>         - Exit denite window in any mode
"   <CR>          - Open currently selected file in any mode
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> <C-o>
  \ <Plug>(denite_filter_quit)
  inoremap <silent><buffer><expr> <Esc>
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> <Esc>
  \ denite#do_map('quit')
  inoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
endfunction

" Define mappings while in denite window
"   <CR>        - Opens currently selected file
"   q/<Esc>/;   - Quit Denite window
"   d           - Delete currenly selected file (just the buffer)
"   p           - Preview currently selected file
"   <C-o> or i  - Switch to insert mode inside of filter prompt
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> <Esc>
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> ;
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <C-o>
  \ denite#do_map('open_filter_buffer')
endfunction

" global find/replace inside cwd
function! FindReplace()
  " figure out which directory we're in
  let dir = getcwd()

  " ask for pattern
  call inputsave()
  let find = input('Pattern: ')
  call inputrestore()
  if empty(find) | return | endif

  " ask for replacement, noting that empty is a valid replacement
  call inputsave()
  let replace = input({ 'prompt': 'Replacement: ', 'cancelreturn': '<ESC>' })
  call inputrestore()
  if replace == '<ESC>' | return | endif
  :mode " clear echoed message

  " confirm each change individually
  let confirmEach = confirm("Do you want to confirm each individual change?", "&Yes\n&No", 2)
  if confirmEach == 0 | return | endif
  :mode

  " are you sure?
  let confirm = confirm('WARNING: Replacing ' . find . ' with ' . replace . ' in ' . dir . '/**/*. Proceed?', "&Yes\n&No", 2)
  :mode

  if confirm == 1
    " record the current buffer so we can return to it at the end
    let currBuff = bufnr("%")

    " find with rigrep (populate quickfix)
    :silent exe 'Rg ' . find

    " use cfdo to substitute on all quickfix files
    if confirmEach == 1
      :noautocmd exe 'cfdo %s/' . find . '/' . replace . '/gc | update'
    else
      :silent noautocmd exe 'cfdo %s/' . find . '/' . replace . '/g | update'
    endif

    " close quickfix window
    :silent exe 'cclose'

    " return to start buffer
    :silent exe 'buffer ' . currBuff

    :echom('Replaced ' . find . ' with ' . replace . ' in all files in ' . dir )
  else
    :echom('Aborted')
  endif
endfunction

" and map it
:nnoremap <Leader>fr :call FindReplace()<CR>


""" vim-easymotion
" Disable default mappings
let g:EasyMotion_do_mapping = 0

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

""" tagbar
nmap <F8> :TagbarToggle<CR>
nmap <F9> :TagbarOpenAutoClose<CR>

