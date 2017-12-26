" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on

" Appearance - dracula and zenburn both nice, at least for python
" colorscheme dracula 
colorscheme zenburn 
set number

" Tabs
set softtabstop=4
set shiftwidth=4
set expandtab

" Search
set ignorecase
set smartcase

" Custom attempt at python mode
" See https://realpython.com/blog/python/vim-and-python-a-match-made-in-heaven/

" set foldmethod=syntax
set foldlevel=1 " fold below top level on file open
let g:SimpylFold_docstring_preview=1

" Enable folding with the spacebar
nnoremap <space> za

" Convenience
" let mapleader=" "

" YouCompleteMe settings
" let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoTo<CR>
map <leader>r  :YcmCompleter GoToReferences<CR>
map <leader>d  :YcmCompleter GetDoc<CR>

" Unknown why, this doesn't work (+ reg doesn't seem to exist) 
" set clipboard=unnamedplus

let python_highlight_all=1

" NERDTree
map <C-n> :NERDTreeToggle<CR>
" This opens with file
" autocmd vimenter * NERDTree
" This opens without file
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

"" Powerline
set rtp+=/home/randy/miniconda3/lib/python3.6/site-packages/powerline/bindings/vim
set laststatus=2
set t_Co =256

" syntastic
" note the following conflict with powerline, so disabling for now
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_jump = 3
let g:syntastic_python_checkers = ["pylint"]
" let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_sort_aggregated_errors = 1

" ultisnips
" Trigger configuration. Do not use <tab> if you use YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsSnippetsDir="~/.vim/bundle/vim-snippets/UltiSnips"

" xml-plugin
let g:xmledit_enable_html=1

" NERDcommenter

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 0 

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
