""" Fresh installation notes
" PlugInstall is run if needed when this file is sourced on startup. Run it
" manually otherwise. This file is probably broken until plugins are installed
" :so % to source it manually
" :checkhealth to ensure plugins are working (only a few are hooked into this
" feature)
"
" Run install.sh to attempt to set everything up automatically
"
" Curl is required to automatically install Plug
" > sudo apt-get install curl
"
" ripgrep (rg) and pynvim must be installed for denite
" > sudo apt-get install ripgrep
" > pip3 install --user pynvim
"
" eslint and prettier-eslint must be installed for javascript per project
" <leader>co (list coc.nvim commands)
" eslint.createConfig
" > yarn add --dev prettier-eslint
"
" In order for floating messages to work in coc.nvim, neovim must
" be built from source (at time of writing, may change).
" > sudo apt-get install cmake libtool libtool-bin
" > git clone https://github.com/neovim/neovim.git
" > git checkout stable
" > make CMAKE_BUILD_TYPE=Release
" > sudo make install
" Alternately, download a prebuilt version. install.sh attempts to do this
"
" neovim sometimes can't find a clipboard provider for unknown reasons.
" The solution seems to be manually installing one, e.g.
" > sudo apt-get install xclip
" (for sharing the system clipboard)
"
" coc needs node (v12.x, obviously this will go out of date at some point)
" > curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
" > sudo apt-get install -y nodejs
"
" tagbar requires universal-ctags
" > sudo snap install universal-ctags
" the following is additionally necessary because of
" https://github.com/universal-ctags/ctags-snap/issues/4
" (shouldn't be in the future)
" > sudo snap connect universal-ctags:dot-ctags
"
" vim-airline needs powerline fonts
" https://powerline.readthedocs.io/en/latest/installation/linux.html#fonts-installation
"
" vim-glaive needs to be installed. there is logic in this script to do that,
" but it needs to be run after :PlugInstall has been run. re-source this file
" or restart vim to install properly.
"
" vim-codefmt requires that formatters be installed elsewhere and in the path.
" currently, I'm only using it for html since prettier is broken and codefmt
" uses js-beautify, so js-beautify would need to be installed for html
" formatting
" > yarn global add js-beautify
"
" the coc c-lang server needs clangd installed.
" see https://clang.llvm.org/extra/clangd/Installation.html
" honestly, it seems quite broken. can't find random files in the path, etc.,
" but leaving in for now
" > sudo apt-get install clangd-9
" > sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100
"
" vim-fugitive needs credentials stored
" > git config --global credential.helper store
" > (any operation that asks for credentials)
" note that my .gitconfig is already set up to do this
"
" jupytext.vim requires that jupytext be installed
" > pip install jupytext

" note that runtime rather than source is used because it doesn't require an
" absolute path (source does, and thus is less portable)
runtime noplug.init.vim

""" Plug

" check whether vim-plug is installed and install it if necessary
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    if executable('curl')
        let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        call system('curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs ' . plugurl)
        if v:shell_error
            echom "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
    else
        echom "vim-plug not installed. Please install it manually or install curl.\n"
        exit
    endif
endif

call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'jnurmine/Zenburn'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'mtth/scratch.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight' " depends on coc
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
Plug 'ggVGc/vim-fuzzysearch'
Plug 'google/vim-maktaba' " vim-codefmt requirement
Plug 'google/vim-glaive' " vim-codefmt requirement
Plug 'google/vim-codefmt'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'sheerun/vim-polyglot'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'airblade/vim-gitgutter'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'tpope/vim-surround'
" NOTE: requires nodejs and yarn to be installed
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'goerz/jupytext.vim'

" this is probably useful for some languages, but unclear if it really
" supports nodejs. turning off for now
" Plug 'idanarye/vim-vebugger'
" Plug 'Shougo/vimproc.vim', {'do' : 'make'} " required for vim-debugger

" this doesn't currently work in neovim due to lack of netbeans support
" Plug 'sidorares/node-vim-debugger'
" Plug 'lrvick/Conque-Shell' " required for node-vim-debugger

call plug#end()

" if any plugins aren't installed, trigger PlugInstall (before VimEnter only)
for key in keys(g:plugs)
  if ! isdirectory(g:plugs[key].dir)
    autocmd VimEnter * PlugInstall
    break
  endif
endfor

" install glaive if it has been loaded
if has_key(g:plugs, "vim-glaive") && isdirectory(g:plugs["vim-glaive"].dir)
  call glaive#Install()
endif

""" colorscheme

" dracula and zenburn both nice, at least for python
" colorscheme dracula
colorscheme zenburn

""" FuzzySearch

" \ - use vim-fuzzysearch in normal mode
nnoremap \ :FuzzySearch<CR>

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

" show hidden files by default
let g:NERDTreeShowHidden = 1

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

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
" Remap toggle comment. Note that _ is actually /. No idea why, but it is
nnoremap <C-_> :call nerdcommenter#Comment(0,"toggle")<CR>
vnoremap <C-_> :call nerdcommenter#Comment(0,"toggle")<CR>
inoremap <C-_> <C-o>:call nerdcommenter#Comment(0,"toggle")<CR>

""" coc.nvim

" extensions
let g:coc_global_extensions=["coc-json", "coc-eslint", "coc-tsserver",
  \ "coc-snippets", "coc-html", "coc-css", "coc-python", "coc-java",
  \ "coc-highlight", "coc-yank", "coc-omnisharp", "coc-emmet",
  \ "coc-lists", "coc-marketplace", "coc-neosnippet", "coc-prettier",
  \ "coc-clangd", "coc-cmake", "coc-xml", "coc-rls" ]

" correct comment highlighting for config file
autocmd FileType json syntax match Comment +\/\/.\+$+

" make sure jsx files are correctly mapped
autocmd BufNewFile,BufRead *.jsx set ft=javascript.jsx
autocmd BufNewFile,BufRead *.tsx set ft=typescript.jsx

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=200

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
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-diagnostic-next)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
nmap <silent> ge <Plug>(coc-diagnostic-next-error)

" Use K to show documentation in preview window. also gh to match VSCode
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> gh :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)

" Remap for format selected region
" I never use these, and considering that I'd need to set them up with the
" html hack below, just leaving them out for now.
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

" Whole buffer
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Prettier breaks up tags onto new lines in a way I don't like in html.
" There may be other reasons to choose a different formatter per file type, so
" encode that here. There are some plugins to organize maps by file type which
" may be better if I want to do more with this, but a simple hack should
" suffice for now.
function RunFormatter()
  if &ft =~ 'html'
    " vim-codefmt
    :FormatCode
  else
    :call CocAction('format')
  endif
endfunction
" Whole buffer map
nmap <leader>b :call RunFormatter()<CR>

" Format on save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html,*.py :call RunFormatter()

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
nnoremap <silent> <leader>co  :<C-u>CocList commands<cr>

" Highlight word under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Yank list
nnoremap <silent> <space>y  :<C-u>CocList --normal yank<cr>

" coc leaves popups open on a fairly regular basis, sometimes obstructing
" large portions of the window and necessitating a restart. the following is a
" partial solution that closes the last window, which seems to always be a
" popup, assuming one is open. this solution isn't ideal, given that it will
" also close the last window if there *isn't* a popup displayed, and the
" assumption that the last window is a popup may be flawed. there is more
" discussion at https://vi.stackexchange.com/q/34654/25078, which will
" hopefully yield a better solution at some point
nnoremap <silent> <leader>' :exec winnr('$').'wincmd c'<cr>

""" denite

" Use ripgrep for searching current directory for files
" By default, ripgrep will respect rules in .gitignore
"   --files: Print each file that would be searched (but don't search)
"   --glob:  Include or excludes files for searching that match the given glob
"            (aka ignore .git files)
"
call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git', '--hidden'])

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

" Remove date from buffer list - I actually don't hate this. Leave it in.
" call denite#custom#var('buffer', 'date_format', '')

" ;         - Browse currently open buffers (starts in filter mode)
" <C-p> - Browse list of files in current directory (starts in filter mode)
" <leader>g - Search current directory for occurences of given term and close window if no results
" <leader>u - Search current directory for occurences of word under cursor
nmap ; :Denite buffer<CR>i
nmap <C-p> :DeniteProjectDir file/rec<CR>i
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>u :<C-u>DeniteCursorWord grep:.<CR>

" Define mappings while in 'filter' mode
"   <C-o>/jk - Quit filter mode
"   <C-c>    - Close denite buffer
"   <Esc>    - Switch to normal mode inside of filter bar (rarely useful)
"   <CR>     - Open currently selected filter
"   <C-v>    - "" in vsplit
"   <C-h>    - "" in split
"   <C-t>    - "" in new tab
"   <C-a>    - Toggle select all
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> <C-o>
  \ <Plug>(denite_filter_update)
  imap <silent><buffer> jk
  \ <Plug>(denite_filter_update)
  imap <silent><buffer> <C-c>
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
  inoremap <silent><buffer><expr> <C-q>
  \ denite#do_map('quit')
endfunction

" Define mappings while in denite window
"   <CR>            - Opens currently selected file
"   <C-v>           - "" in vsplit
"   <C-h>           - "" in split
"   <C-t>           - "" in new tab
"   q/<Esc>/;/<C-c> - Quit Denite window
"   d               - Delete currenly selected file (just the buffer)
"   p               - Preview currently selected file
"   <C-o> or i      - Switch to insert mode inside of filter prompt
"   <C-Space>       - Toggle select
"   <C-a>           - Toggle select all
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> <C-c>
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

""" vim-easymotion

" Disable default mappings
let g:EasyMotion_do_mapping = 0

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `f{char}{label}`
nmap f <Plug>(easymotion-overwin-f)
" or
" `f{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
" nmap f <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" Gif config
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

""" tagbar

nmap <F8> :TagbarToggle<CR>
nmap <F9> :TagbarOpenAutoClose<CR>
nmap <C-t> :TagbarOpenAutoClose<CR>\

""" emmet-vim

" remap leader (type, then \, to expand)
let g:user_emmet_leader_key='\'
let g:user_emmet_mode='i'

""" nerdtree-git-plugin

let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

""" vim-outdated-plugins

let g:outdated_plugins_silent_mode = 0
let g:outdated_plugins_trigger_mode = 0
autocmd VimEnter * call CheckOutdatedPlugins()

""" vim-fugitive

command! -bang -nargs=* Gcommit tab Git<bang> commit <args>
command! -bang -nargs=* Gstatus tab Git<bang> <args>
command! -bang -nargs=* Glog tab Gclog!<bang> <args>

""" vim-ripgrep

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
    " note the need to escape special chars to align with very magic mode.
    " this is probably not an exhaustive list
    let rgFind = substitute(find, '\\', '\\\\', 'g')
    let rgFind = substitute(rgFind, '*', '\\*', 'g')
    let rgFind = substitute(rgFind, '[', '\\[', 'g')
    let rgFind = substitute(rgFind, ']', '\\]', 'g')
    let rgFind = substitute(rgFind, '<\|>', '\\\\b', 'g')
    :silent exe 'Rg --hidden --glob !.git ' . rgFind

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
:nnoremap <leader>fr :call FindReplace()<CR>

