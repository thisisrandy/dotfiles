""" Fresh installation notes
" PlugInstall is run if needed when this file is sourced on startup. Run it
" manually otherwise. This file is probably broken until plugins are installed
" :so % to source it manually
" :checkhealth to ensure plugins are working (only a few are hooked into this
" feature)
"
" Run install.sh to attempt to set everything up automatically
"
" NOTE: I don't maintain the notes below anymore. Some of them are still
" useful if one is wondering why something is included in install.sh, but
" others are obsolete or refer to plugins I no longer use.
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

" this virtualenv must of course exist and have the neovim package installed
" in it. install.sh takes care of that
let g:python3_host_prog = '~/.pyenv/versions/neovim/bin/python'

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

" when remote plugins are first installed (or updated), UpdateRemotePlugins
" needs to be run. there's a way to trigger this via plugged, but there's also
" some sort of bug with doing it directly. according to
" https://github.com/gelguy/wilder.nvim/issues/109#issuecomment-1007682696,
" this is a workaround
function! UpdateRemotePlugins(...)
  " Needed to refresh runtime files
  let &rtp=&rtp
  UpdateRemotePlugins
endfunction


call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'jnurmine/Zenburn'
Plug 'EdenEast/nightfox.nvim'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'mtth/scratch.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight' " depends on coc
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-dadbod'
Plug 'cohama/lexima.vim'
Plug 'wesQ3/vim-windowswap'
Plug 'alvan/vim-closetag'
Plug 'thisisrandy/vim-outdated-plugins', { 'do': function('UpdateRemotePlugins') }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'sheerun/vim-polyglot'
Plug 'airblade/vim-gitgutter'
Plug 'jeffkreeftmeijer/vim-numbertoggle', { 'branch': 'main' }
Plug 'tpope/vim-surround'
" NOTE: requires nodejs and yarn to be installed
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'goerz/jupytext.vim'
Plug 'andymass/vim-matchup'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" see https://github.com/antoinemadec/coc-fzf/issues/118
" Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
Plug 'thisisrandy/coc-fzf', {'branch': 'symbols-fix'}

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

""" colorscheme

" colorscheme zenburn
" colorscheme nightfox
colorscheme gruvbox

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
" the nice powerline colnr symbol was removed in
" https://github.com/vim-airline/vim-airline/commit/aee282c964060fdba9ad7f8d2f22973c4549cd9a
" and replaced with the care of symbol (\u2105). my font definitely includes
" \ue0a3, so override with the old symbol
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.colnr = ' :'

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
inoremap <C-_> <Cmd>call nerdcommenter#Comment(0,"toggle")<CR>
" Custom delimiters for [JT]SX commenting. Switch to alt using <leader>ca
" (mnemonic: comment alt)
let g:NERDCustomDelimiters={
    \ 'javascriptreact': { 'left': '//', 'right': '', 'leftAlt': '{/*', 'rightAlt': '*/}' },
    \ 'typescriptreact': { 'left': '//', 'right': '', 'leftAlt': '{/*', 'rightAlt': '*/}' },
    \}

""" coc.nvim

" extensions
let g:coc_global_extensions=["coc-json", "coc-eslint", "coc-tsserver",
  \ "coc-snippets", "coc-html", "coc-css", "coc-pyright", "coc-java",
  \ "coc-highlight", "coc-yank", "coc-omnisharp", "coc-emmet",
  \ "coc-lists", "coc-marketplace", "coc-prettier", "coc-clangd",
  \ "coc-cmake", "coc-xml", "coc-rls" ]

" correct comment highlighting for config file
autocmd FileType json syntax match Comment +\/\/.\+$+

" make sure jsx files are correctly mapped. this was added in 200f7598, but
" I'm unable currently to find any justification for it. in fact, it breaks
" color schemes under some conditions involving template literals. possibly
" the need for it has been obviated by improvements to coc. commenting out but
" leaving in to address the possibility that the utility of these autocommands
" is rediscovered later on
" autocmd BufNewFile,BufRead *.jsx set ft=javascript.jsx
" autocmd BufNewFile,BufRead *.tsx set ft=typescript.jsx

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=200

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
  \ coc#pum#visible() ? coc#_select_confirm() :
  \ coc#expandableOrJumpable() ?
  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <c-space> to trigger completion in insertion mode
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-diagnostic-next)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
" I never use this (gn & gp are sufficient), and it shadows a mapping that I
" care about (end of previous word), so remove it for now
" nmap <silent> ge <Plug>(coc-diagnostic-next-error)

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

" Map for outline
nmap <leader>o :CocOutline<CR>
" make the outline close itself once it's no longer in focus
autocmd BufLeave CocTree* q

function RunFormatter()
  if &ft =~ 'vim'
    :exec "norm! gg=G\<C-o>"
  else
    :call CocAction('format')
  endif
endfunction

" Whole buffer map
nmap <leader>b :call RunFormatter()<CR>

" Format on save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,
            \ *.graphql,*.md,*.vue,*.yaml,*.html,*.py,*.rs,*.hs
            \ :call RunFormatter()

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  " this line overrides gq for ts & json, which I don't like. it enables
  " selection formatting, which I don't care about. therefore it's not used
  " autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Open codeAction menu for the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <C-.>  <Plug>(coc-fix-current)
" Run the Code Lens action on the current line.
nmap <leader>al  <Plug>(coc-codelens-action)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

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

""" fzf

" From most windows, <C-t> opens in new tab, <C-x> in split, and <C-v> in
" vertical split

" ;         - Browse currently open buffers
" <C-p> - Browse list of files in current directory
" <leader>g - Search current directory for occurences of given term and close window if no results
" <leader>u - Search current directory for occurences of word under cursor
nnoremap <silent> ; :Buffers<CR>
nnoremap <silent> <C-p> :Files<CR>
nnoremap <leader>g :Rg<space>
nnoremap <silent> <leader>u yiw :Rg <C-r>"<CR>

""" coc-fzf
nnoremap <silent> <leader><leader> :<C-u>CocFzfList<CR>
nnoremap <silent> <leader>aa       :<C-u>CocFzfList diagnostics<CR>
nnoremap <silent> <leader>ab       :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> <leader>co       :<C-u>CocFzfList commands<CR>
nnoremap <silent> <leader>e        :<C-u>CocFzfList extensions<CR>
nnoremap <silent> <leader>l        :<C-u>CocFzfList location<CR>
nnoremap <silent> <C-t>            :<C-u>CocFzfList outline<CR>
nnoremap <silent> <leader>s        :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <leader>r        :<C-u>CocFzfListResume<CR>

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

""" tagbar (currently unused)

" nmap <F8> :TagbarToggle<CR>
" nmap <F9> :TagbarOpenAutoClose<CR>
" nmap <C-t> :TagbarOpenAutoClose<CR>\

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

""" vim-windowswap

" prevent default bindings and then remap easy swap only
let g:windowswap_map_keys = 0
nnoremap <silent> <leader>ww :call WindowSwap#EasyWindowSwap()<CR>
