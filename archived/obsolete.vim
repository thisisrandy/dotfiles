" WHY: far.vim is about a million times better than this. still, I was pretty
" proud of myself for writing a useful vimscript function when I first did
" this, so keep it around in the archive
"
" global find/replace inside cwd. this requires ripgrep be in the path, but
" nothing else. compared to the greplace plugin, it takes fewer keystrokes,
" and can leverage rg's "smart" search, but there's something of a price:
" files which aren't already open in a buffer get opened without a filetype,
" so all of the functionality which depends on filetype isn't available until
" the buffers are closed and reopened. greplace is getting around that by
" actually editing each file and then hiding it before moving onto the next
" one, which cfdo apparently does not
" TODO: try to figure a way to get cfdo to properly open each file
" TODO: why am I specifying that the input pattern isn't just ripgrep's native
" syntax? should change to just use that directly
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

  " check if we're going to be
  let searchHidden = confirm("Do you want to include hidden files?", "&Yes\n&No", 2)
  if searchHidden == 0 | return | endif
  :mode

  " confirm each change individually
  let confirmEach = confirm("Do you want to confirm each individual change?", "&Yes\n&No", 2)
  if confirmEach == 0 | return | endif
  :mode

  " are you sure?
  let confirm = confirm('Replacing pattern "' . find . '" with string "' . replace . '" in ' . dir . '/**/*. Proceed?', "&Yes\n&No", 2)
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

    let l:grepprgb = &grepprg
    let l:grepformatb = &grepformat
    let &grepprg = 'rg --vimgrep'
    if searchHidden == 1
      let &grepprg = &grepprg . ' --hidden'
    endif
    let &grepformat = '%f:%l:%c:%m'

    :silent exe 'grep! ' . rgFind

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

    :echom('Replaced "' . find . '" with "' . replace . '" in all files in ' . dir )

    let &grepprg = l:grepprgb
    let &grepformat = l:grepformatb
  else
    :echom('Aborted')
  endif
endfunction

" and map it
:nnoremap <leader>fr :call FindReplace()<CR>


