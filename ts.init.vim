""" What is this file?
" This is a version of my init.vim which uses treesitter. Treesitter has
" proven to be often buggy and overly resource hungry for use on my aging
" machine. As such, this is now my non-default setup, at least for a while.
"
" NOTE: nvim-treesitter does best on the nightly nvim build. it may break
" quite catastrophically if run on stable.
"
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

" I've forked this in order to remove some conflicting mappings. it seems
" unlikely to change much in the future, so maintenance should be nil
Plug 'thisisrandy/vim-unimpaired'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'PhilRunninger/nerdtree-visual-selection'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'mtth/scratch.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jackguo380/vim-lsp-cxx-highlight' " depends on coc
Plug 'phaazon/hop.nvim', { 'branch': 'v2' }
Plug 'tpope/vim-dadbod'
Plug 'cohama/lexima.vim'
Plug 'wesQ3/vim-windowswap'
Plug 'alvan/vim-closetag'
Plug 'thisisrandy/vim-outdated-plugins', { 'do': function('UpdateRemotePlugins') }
Plug 'airblade/vim-gitgutter'
Plug 'jeffkreeftmeijer/vim-numbertoggle', { 'branch': 'main' }
Plug 'tpope/vim-surround'
" NOTE: requires nodejs and yarn to be installed
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'goerz/jupytext.vim'
Plug 'andymass/vim-matchup'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf'
Plug 'brooth/far.vim', { 'do': function('UpdateRemotePlugins') }
Plug 'simnalamburt/vim-mundo'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-repeat'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'numToStr/Comment.nvim'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'p00f/nvim-ts-rainbow'
Plug 'jpalardy/vim-slime'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-treesitter/nvim-treesitter-refactor'
Plug 'dhruvasagar/vim-zoom'
Plug 'folke/which-key.nvim'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'inkarkat/vim-AdvancedSorters', {'branch': 'stable'}
Plug 'Yggdroot/indentLine'
Plug 'chaoren/vim-wordmotion'
Plug 'haya14busa/vim-asterisk'
Plug 'wellle/targets.vim'

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

map <silent> <C-n> :NERDTreeToggle<CR>
nmap <silent> <C-f> :NERDTreeFind<CR>

" quit if last window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" show hidden files by default
let g:NERDTreeShowHidden = 1
" but ignore .git
let g:NERDTreeIgnore = ['^.git$']

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
      \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" close NERDTree only when we've used it to open a file
let g:NERDTreeQuitOnOpen = 1
" close NERDTree we leave it otherwise
" autocmd BufLeave * if bufname('%') =~ 'NERD_tree_\d\+' | q | endif

""" vim-devicons

" FIXME: this doesn't work, though I'm not entirely sure I care enough to dig
" in. I suspect the issue is neovim
let g:webdevicons_enable_airline_statusline = 1

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

""" coc.nvim

" extensions
let g:coc_global_extensions=["coc-json", "coc-eslint", "coc-tsserver",
      \ "coc-snippets", "coc-html", "coc-css", "coc-pyright", "coc-java",
      \ "coc-highlight", "coc-yank", "coc-omnisharp", "coc-emmet",
      \ "coc-lists", "coc-marketplace", "coc-prettier", "coc-clangd",
      \ "coc-cmake", "coc-xml", "coc-rust-analyzer", "coc-sh", "coc-lua",
      \ "coc-dictionary", "coc-emoji", "coc-toml"]
" dictionary completions seem to mostly just get in the way, so disable them
" unless a special variable is set. I have command aliases set up to do this
if $COC_USE_DICT == ""
  autocmd VimEnter * call CocActionAsync("deactivateExtension", "coc-dictionary")
endif
" the above doesn't survive across restarts. a quick hack to address that is
" to provide a custom command that restarts and then potentially deactivates
" the dictionary
function! s:CocRestartDeactivateDictionary() abort
  :CocRestart
  if $COC_USE_DICT == ""
    call CocActionAsync("deactivateExtension", "coc-dictionary")
  endif
endfunction
command! -nargs=0 CRestart call <sid>CocRestartDeactivateDictionary()

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

nmap <silent> gd <Plug>(coc-definition)
" gd is a built-in heuristic lookup that usually functions well in vimscript
" files. Make sure it isn't shadowed when one is open. Note that there doesn't
" appear to be a way to unmap a global mapping in a buffer context, but the
" easy workaround is just to noremap it to itself
autocmd FileType vim nnoremap <silent> <buffer> gd gd
" For reference, an alternate way to do this would be something like
" autocmd FileType * if &ft!="vim"|nmap <buffer> <silent> gd <Plug>(coc-definition)|endif
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Grepping for the word under the cursor is a reasonable proxy for references
" when no language server is available. This is the same as my <leader>u map
autocmd FileType vim nnoremap <silent> <buffer> gr :execute "Rgf " . expand("<cword>")<cr>
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
nmap <silent> <F2> <Plug>(coc-rename)

" make the outline close itself once it's no longer in focus. open map is via
" which-key
autocmd BufLeave CocTree* q

" note that buffer format map is via which-key
function! RunFormatter()
  if &ft =~ 'vim' || &ft =~ 'sh'
    let winView = winsaveview()
    exec "norm! gg=G"
    call winrestview(winView)
  else
    call CocAction('format')
  endif
endfunction

" Format on save
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html,*.py,*.rs,*.hs,*.toml,*.c,*.cc,*.ccp :call RunFormatter()

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  " this line overrides gq for ts & json, which I don't like. it enables
  " selection formatting, which I don't care about. therefore it's not used
  " autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Highlight word under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

""" fzf

" From most windows, <C-t> opens in new tab, <C-x> in split, and <C-v> in
" vertical split

" ;         - Browse currently open buffers
" <C-p> - Browse list of files in current directory
" a variety of other maps are created via which-key
nnoremap <silent> ; :Buffers<CR>
nnoremap <silent> <C-p> :Files<CR>

let s:rg_base_cmd = "rg --column --line-number --no-heading --color=always --smart-case"
" Identical to Rg defined in fzf.vim except for the -u flag, which causes
" ripgrep to include .gitignore'd files
command! -bang -nargs=* Rgu call fzf#vim#grep((s:rg_base_cmd . " -u -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
" additionally include hidden files and directories
command! -bang -nargs=* Rguu call fzf#vim#grep((s:rg_base_cmd . " -uu -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
" additionally include binary files
command! -bang -nargs=* Rguuu call fzf#vim#grep((s:rg_base_cmd . " -uuu -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
" Identical to Rg except for the -F flag, which causes rg to treat the pattern
" as a fixed string instead of a regexp
command! -bang -nargs=* Rgf call fzf#vim#grep((s:rg_base_cmd . " -F -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
" u, uu, and uuu for fixed strings
command! -bang -nargs=* Rgfu call fzf#vim#grep((s:rg_base_cmd . " -F -u -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Rgfuu call fzf#vim#grep((s:rg_base_cmd . " -F -uu -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Rgfuuu call fzf#vim#grep((s:rg_base_cmd . " -F -uuu -- ").shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

""" coc-fzf

" make coc-fzf windows open fullscreen in a new tab. since they display with
" preview above filter text in a horizontal split, this is a much nicer
" experience
let g:coc_fzf_preview_fullscreen = 1

function! s:searchOutline()
  " this is an inexhaustive list of filetypes I don't have a language server
  " installed for. fzf.nvim's :BTags works even when a tags file hasn't been
  " generated. this *does not* cover the jump to definition (C-]) case, which
  " requires a tags file. I've made no attempt to auto-generate those, though
  " it seems easy enough to do were I to start editing these file types often.
  " were that the case, I'd probably also want to selectively change the
  " behavior of gh to C-] and pull non-lsp file types out into a variable
  if (index(['vim','perl'], &filetype) >= 0)
    :BTags
  else
    :CocFzfList outline
  endif
endfunction

" note that leader maps are via which-key
nnoremap <silent> <C-t> :call <SID>searchOutline()<CR>

""" hop.nvim - modern easymotion replacement

lua<<EOF
local hop = require('hop')
hop.setup()
vim.keymap.set('', 'f', hop.hint_char1)
vim.keymap.set('', 'F', (function() hop.hint_char1({current_line_only = true}) end))
vim.keymap.set('', 't', hop.hint_patterns)
vim.keymap.set('', 'T', (function() hop.hint_patterns({current_line_only = true}) end))
EOF

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

""" vim-windowswap

" prevent default bindings and then remap easy swap only (via which-key)
let g:windowswap_map_keys = 0

""" vim-gitgutter

" prevent default mappings so that which-key can handle leader maps
let g:gitgutter_map_keys = 0
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

""" far

" enable undo shortcut (u)
let g:far#enable_undo=1
let g:far#source='rgnvim'
let g:far#glob_mode='native'
set lazyredraw
" maps via which-key

""" Mundo
nnoremap <silent> <F5> :MundoToggle<CR>
" the following sets up persistent undos, but it's unacceptably slow for files
" with long histories. it seems pretty rare that I'd want the entire undo
" history for a file, anyways (SCM is a much better solution to that problem).
" a nice compromise is to use a tmp dir so that the undo history from the
" session only is persisted (assuming default tmp file cleanup settings. see
" man tmpfiles.d)
set undofile
set undodir=/tmp/.vim/undo
let g:mundo_width = 80
let g:mundo_preview_height = 30
let g:mundo_right = 1
let g:mundo_close_on_revert = 1
let g:mundo_mirror_graph = 0
let g:mundo_auto_preview_delay = 100

""" nvim-treesitter and friends

lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- nvim-treesitter
  ensure_installed = {
    "c",
    "cpp",
    "rust",
    "java",
    "python",
    "lua",
    "vim",
    "haskell",
    "javascript",
    "typescript",
    "tsx",
    "sql",
    "json",
    "css",
    "scss",
    "html",
    "markdown",
    "yaml",
  },
  highlight = {
    enable = true,
    -- disabled for typescript while
    -- https://github.com/nvim-treesitter/nvim-treesitter/issues/4362 is open
    disable = { "typescript" }
  },
  indent = {
    enable = true,
    -- this breaks indentation in python. see
    -- https://github.com/nvim-treesitter/nvim-treesitter/issues/2947
    -- it also breaks adding items to the end of lists in yaml
    disable = {"python", "yaml"},
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<M-S-left>",
      node_incremental = "<M-S-left>",
      -- this isn't a whole lot different from node_incremental. it's much
      -- easier to just mirror the vscode bindings instead
      -- scope_incremental = "<leader>is",
      node_decremental = "<M-S-right>",
    },
  },

  -- nvim-treesitter-refactor
  refactor = {
    highlight_definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100.
      clear_on_cursor_move = true,
    },
    -- highlight is kind of cool, but it's also kind of distracting, a bit
    -- buggy, and most importantly, conflicts with the effect of
    -- coc-highlight. turning off for now
    -- highlight_current_scope = { enable = true },
    -- refactor provides two other modules, smart_rename and navigation,
    -- but they both seem to suck. lsp from coc is much more (if not 100%)
    -- reliable
  },

  -- nvim-treesitter-textobjects
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      --
      -- Note that this doesn't apply to visual selection, which instead uses
      -- visualmode() to select the mode
      selection_modes = 'V',

      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = false,
    },

    -- swap = {
    --   enable = true,
    --   swap_next = {
    --     ["<leader>s"] = "@parameter.inner",
    --   },
    --   swap_previous = {
    --     ["<leader>S"] = "@parameter.inner",
    --   },
    -- },

    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]]"] = "@block.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]["] = "@block.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[["] = "@block.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[]"] = "@block.outer",
      },
    },
  },

  -- nvim-ts-context-commentstring
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
    config = {
      javascript = {
        __default = '// %s',
        jsx_element = '{/* %s */}',
        jsx_fragment = '{/* %s */}',
        jsx_attribute = '// %s',
        comment = '// %s'
      },
    },
  },

  -- vim-matchup
  matchup = {
    enable = true,              -- mandatory, false will disable the whole extension
    disable = {},               -- optional, list of language that will be disabled
    -- [options]
  },

  -- nvim-ts-rainbow
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
}
EOF

" see https://github.com/p00f/nvim-ts-rainbow/issues/112
" TS rainbow isn't very good at staying sane after file edits. until it
" improves, here's a hack to just turn it off and on again after every write
autocmd BufWritePost * TSDisable rainbow | TSEnable rainbow
" I also observed that the behavior improves after a few disable/enable
" cycles. here's a jumpstart
autocmd BufReadPost,BufNewFile * TSDisable rainbow | TSEnable rainbow | TSDisable rainbow | TSEnable rainbow | TSDisable rainbow | TSEnable rainbow

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=99
nnoremap - zc
nnoremap = zo
" just in case we want to use indent on something
nnoremap \ =
" make visual map match
vnoremap \ =
nnoremap + zO
" also make a shortcut to mostly folded
nnoremap <silent> z1 :set foldlevel=1<CR>

""" Comment.nvim

lua << EOF
require('Comment').setup {
  -- per https://github.com/JoosepAlviste/nvim-ts-context-commentstring#nvim-comment
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
}
EOF

nmap <C-_> gcc
vmap <C-_> gc
imap <C-_> <C-o>gcc

""" vim-slime

let g:slime_target = "tmux"
let g:slime_paste_file = tempname()
let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
let g:slime_python_ipython = 1

""" which-key.nvim

" which-key works for any timeoutlen, including 0, so turn it down from the
" 500 in noplug.init.vim
set timeoutlen=250

lua<<EOF
local wk = require('which-key')

wk.setup { plugins = { spelling = { enabled = true } } }

wk.register({
  b = {
    name = '+[b]lackhole-delete',
    c = {'"_c', '[c]hange'},
    C = {'"_C', '[C]hange to EOL'},
    d = {'"_d', '[d]elete'},
    D = {'"_D', '[D]elete to EOL'},
  },
  c = {
    name = '+[c]oc',
    a = {':CocFzfList diagnostics<CR>', 'di[a]gnostics (project)'},
    b = {':CocFzfList diagnostics --current-buf<CR>', 'diagnostics (current [b]uffer)'},
    c = {'<Plug>(coc-codeaction)', '[c]odeactions'},
    d = {'<Plug>(coc-codelens-action)', 'co[d]elens action'},
    e = {':CocFzfList extensions<CR>', '[e]xtensions'},
    f = {':call RunFormatter()<CR>', '[f]ormat buffer'},
    l = {':CocFzfList location<CR>', '[l]ocations list'},
    m = {':CocFzfList<CR>', 'list of lists ([m]eta)'},
    n = {':CocFzfList commands<CR>', 'comma[n]ds'},
    o = {':CocOutline<CR>', '[o]utline'},
    r = {':CocFzfListResume<CR>', '[r]esume last list'},
    s = {':CocFzfList symbols<CR>', '[s]ymbols'},
    x = {'<Plug>(coc-fix-current)', 'autofi[x]'},
    y = {':CocFzfList yank<CR>', '[y]ank list'},
  },
  f = {':Farr<CR>', '[f]ind/replace'},
  h = {
    name = '+[h]unks',
    p = {'<Plug>(GitGutterPreviewHunk)', '[p]review hunk'},
    s = {'<Plug>(GitGutterStageHunk)', '[s]tage hunk'},
    u = {'<Plug>(GitGutterUndoHunk)', '[u]ndo hunk'},
  },
  l = {
    name = '+[l]ines',
    a = {':Lines<CR>', 'lines search ([a]ll buffers)'},
    b = {':BLines<CR>', 'lines search (current [b]uffer)'},
  },
  o = {':nohlsearch<CR>', 'highlight [o]ff'},
  s = {
    name = '+[s]earch',
    b = {':BCommits<CR>', 'commits ([b]uffer)'},
    c = {':Commits<CR>', '[c]ommits'},
    h = {':History:<CR>', 'command [h]istory'},
    o = {':Commands<CR>', 'c[o]mmands'},
    s = {':History/<CR>', '[s]earch history'},
  },
  t = {
    name = '+[t]abs',
    c = {':tabclose<CR>', '[c]lose'},
    f = {':tabfirst<CR>', '[f]irst'},
    l = {':tablast<CR>', '[l]ast'},
    n = {':tabnext<CR>', '[n]ext'},
    o = {':tabonly<CR>', '[o]nly'},
    p = {':tabprevious<CR>', '[p]revious'},
    t = {':tabs<CR>', '[t]abs (list)'},
    w = {':tabnew<CR>', 'ne[w]'},
  },
  u = {':execute "Rgf " . expand("<cword>")<CR>', 'ripgrep word [u]nder cursor'},
  w = {
    name = '+[w]rap/windows',
    r = {':call ToggleWrap()<CR>', 'toggle line w[r]ap'},
    w = {':call WindowSwap#EasyWindowSwap()<CR>', '[w]indow swap'},
  },
  x = {
    name = '+conte[x]t',
    d = {':ContextDisable<CR>', '[d]isable'},
    e = {':ContextEnable<CR>', '[e]nable'},
    t = {':ContextToggle<CR>', '[t]oggle'},
  },
}, { prefix = '<leader>' })

wk.register({
  d = {
    name = '+[d]iff',
    a = { ':diffpatch ', 'p[a]tch from file' },
    g = { ':diffget<CR>', '[g]et (from other)' },
    o = { ':diffoff<CR>', '[o]ff (current buffer)' },
    O = { ':diffoff!<CR>', '[O]ff! (all in tab)' },
    p = { ':diffput<CR>', '[p]ut (to other)' },
    s = { ':diffsplit ', 'horizontal [s]plit' },
    t = { ':diffthis<CR>', '[t]his' },
    v = { ':vertical diffsplit ', '[v]ertical split' },
    u = { ':diffupdate<CR>', '[u]pdate' },
  },
  g = {':Rg ', 'rip[g]rep'}
}, { prefix = '<leader>', silent = false })

wk.register({
  b = {
    name = '+[b]lackhole-delete',
    c = {'"_c', 'overwrite (using [c])'},
    d = {'"_d', '[d]elete'},
    p = {'"_dP', '[p]aste'},
  },
  h = {
    name = '+[h]unks',
    s = {'<Plug>(GitGutterStageHunk)', '[s]tage hunk'},
  },
  u = {'y :Rgf <C-r>"<CR>', 'ripgrep selected text ([u]nder cursor)'},
  }, { prefix = '<leader>', mode = 'v' })
EOF

""" vim-speeddating

autocmd Vimenter * :SpeedDatingFormat %m/%d/%Y

""" vim-wordmotion

" I don't really use the WORD motions, and I'm finding wordmotion getting
" in the way a lot of the time, so overwrite the WORD motions with wordmotions
" CamelCase etc. motions
" Note: Annoyingly, vim fails to parse the closing brace when this is on multiple lines
let g:wordmotion_mappings = { "w": "W", "b": "B", "e": "E", "ge": "gE", "aw": "aW", "iw": "iW", "<C-R><C-W>": "<C-R><C-A>", }

""" vim-asterisk

" Set the z (stay) behavior as default
map *  <Plug>(asterisk-z*)
map #  <Plug>(asterisk-z#)
map g* <Plug>(asterisk-gz*)
map g# <Plug>(asterisk-gz#)
" And stay in position when selecting the next match
let g:asterisk#keeppos = 1
