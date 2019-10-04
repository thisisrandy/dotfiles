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
" Extensions: coc-json, coc-eslint, coc-tsserver, coc-snippets, coc-html,
"             coc-css, coc-python, coc-java...
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
"
" vim-airline needs powerline fonts
" https://powerline.readthedocs.io/en/latest/installation/linux.html#fonts-installation

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
Plug 'tpope/vim-dadbod'
Plug 'majutsushi/tagbar'
Plug 'cohama/lexima.vim'
Plug 'wesQ3/vim-windowswap'
Plug 'jremmen/vim-ripgrep'
Plug 'alvan/vim-closetag'
Plug 'mattn/emmet-vim'
" Plug 'semanser/vim-outdated-plugins'
Plug 'thisisrandy/vim-outdated-plugins'

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

" Remap window resizing. This is a little weird, since it isn't window
" placement-aware, but it'll do
nnoremap <C-S-Left> :vertical resize -1<CR>
nnoremap <C-S-Right> :vertical resize +1<CR>
nnoremap <C-S-Down> :resize -1<CR>
nnoremap <C-S-Up> :resize +1<CR>

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

" / - search in very magic mode
" <leader>h - Find and replace
" <leader>/ - Clear highlighted search terms while preserving history
nmap / /\v
nmap <leader>h :%s/\v//<left><left>
vmap <leader>h :s/\v//<left><left>
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

" save in insert mode
inoremap <C-s> <C-o>:w<CR>

" mappings to cut and paste into the "black hole register"
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

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
nmap <leader>r <Plug>(coc-rename)

" Remap for format selected region
" I never use these, and considering that I'd need to set them up with the
" html hack below, just leaving them out for now.
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

" Whole buffer
command! -nargs=0 Prettier :CocCommand prettier.formatFile
" Prettier breaks up tags onto new lines in a way I don't like in html. This
" seems to be a functioning hack around that behavior.
function PrettierHtmlHack()
  if &ft =~ 'html'
    " for some reason Prettier ignores the s/r operation if I don't write the
    " buffer out first. super-annoying, especially since BufWritePre (below)
    " behaves differently. I'm tired of trying to figure out why, though, so
    " I guess this is what we're doing
    :%s/></>\r</ge | update | Prettier
  else
    :call CocAction('format')
  endif
endfunction
" Whole buffer map
" nmap <leader>b <Plug>(coc-format)
nmap <leader>b :call PrettierHtmlHack()<CR>

" Format on save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml Prettier
" same as PrettierHtmlHack above, but for some reason don't need to write out
" for Prettier to respect the s/r changes
autocmd BufWritePre *.html %s/></>\r</ge | Prettier
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

" ;         - Browser currently open buffers
" <leader>t - Browse list of files in current directory
" <leader>g - Search current directory for occurences of given term and close window if no results
" <leader>u - Search current directory for occurences of word under cursor
nmap ; :Denite buffer<CR>
nmap <leader>t :DeniteProjectDir file/rec<CR>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>u :<C-u>DeniteCursorWord grep:.<CR>

" Define mappings while in 'filter' mode
"   <C-o>/<Esc> - Switch to normal mode inside of search results
"   <CR>        - Open currently selected filter
"   <C-v>       - "" in vsplit
"   <C-h>       - "" in split
"   <C-t>       - "" in new tab
"   <C-a>       - Toggle select all
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> <C-o>
  \ <Plug>(denite_filter_quit)
  inoremap <silent><buffer><expr> <Esc>
  \ <Plug>(denite_filter_quit)
  inoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  inoremap <silent><buffer><expr> <C-h>
  \ denite#do_map('do_action', 'split')
  inoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  inoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  inoremap <silent><buffer><expr> <C-a>
  \ denite#do_map('toggle_select_all')
endfunction

" Define mappings while in denite window
"   <CR>        - Opens currently selected file
"   <C-v>       - "" in vsplit
"   <C-h>       - "" in split
"   <C-t>       - "" in new tab
"   q/<Esc>/;   - Quit Denite window
"   d           - Delete currenly selected file (just the buffer)
"   p           - Preview currently selected file
"   <C-o> or i  - Switch to insert mode inside of filter prompt
"   <C-Space>   - Toggle select
"   <C-a>       - Toggle select all
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
  nnoremap <silent><buffer><expr> <C-h>
  \ denite#do_map('do_action', 'split')
  nnoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  nnoremap <silent><buffer><expr> <C-Space>
  \ denite#do_map('toggle_select').'j'
  nnoremap <silent><buffer><expr> <C-a>
  \ denite#do_map('toggle_select_all')
endfunction

" global find/replace inside cwd
function! FindReplace()
  " figure out which directory we're in
  let dir = getcwd()

  " ask for pattern
  call inputsave()
  let find = input('Pattern (very magic mode): ')
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
    " note the need to escape special chars to align with v-mode.
    " this is probably not an exhaustive list
    let rgFind = substitute(find, '\\', '\\\\', 'g')
    let rgFind = substitute(rgFind, '*', '\\*', 'g')
    let rgFind = substitute(rgFind, '[', '\\[', 'g')
    let rgFind = substitute(rgFind, ']', '\\]', 'g')
    :silent exe 'Rg ' . rgFind

    " use cfdo to substitute on all quickfix files
    if confirmEach == 1
      :noautocmd exe 'cfdo %s/\v' . find . '/' . replace . '/gc | update'
    else
      :silent noautocmd exe 'cfdo %s/\v' . find . '/' . replace . '/g | update'
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
nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
" nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

""" tagbar
nmap <F8> :TagbarToggle<CR>
nmap <F9> :TagbarOpenAutoClose<CR>

""" emmet-vim
" remap leader (type, then ,, to expand)
let g:user_emmet_leader_key=','

" restrict to html and css files
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall


