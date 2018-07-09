" First some checks {{{1
if exists("g:CiderVinegarEnableNERDTree") && g:CiderVinegarEnableNERDTree == 1
  if g:NERDTreeHijackNetrw != 1
    let g:NERDTreeHijackNetrw = 1
    echomsg "CiderVinegar set g:NERDTreeHijackNetrw to 1."
  endif
  if g:NERDTreeQuitOnOpen != 1
    let g:NERDTreeQuitOnOpen = 1
    echomsg "CiderVinegar set g:NERDTreeQuitOnOpen to 1."
  endif
endif

if exists("g:CiderVinegarEnableBuffergator") && g:CiderVinegarEnableBuffergator == 1
  if g:buffergator_viewport_split_policy != "N"
    let g:buffergator_viewport_split_policy = "N"
    echomsg "CiderVinegar set g:buffergator_viewport_split_policy to N."
  endif
endif

" Commands and Keymaps {{{1
command! CiderVinegar call CiderVinegar()
command! CiderVinegarBuffers call CiderVinegarBuffers()
command! CiderVinegarQF call CiderVinegarToggleList("QuickFix List", "c")
command! CiderVinegarLL call CiderVinegarToggleList("Location List", "l")

if exists("g:CiderVinegarToggle")
      \ && exists("g:CiderVinegarEnableNERDTree")
      \ && g:CiderVinegarEnableNERDTree == 1
  execute "nnoremap " . g:CiderVinegarToggle . " :CiderVinegar<CR>"
endif
if exists("g:CiderVinegarToggleBuffers") 
      \ && exists("g:CiderVinegarEnableBuffergator") 
      \ && g:CiderVinegarEnableBuffergator == 1
  execute "nnoremap " . g:CiderVinegarToggleBuffers . " :CiderVinegarBuffers<CR>"
endif
if exists("g:CiderVinegarToggleQF")
  execute "nnoremap " . g:CiderVinegarToggleQF . " :CiderVinegarQF<CR>"
endif
if exists("g:CiderVinegarToggleLL")
  execute "nnoremap " . g:CiderVinegarToggleLL . " :CiderVinegarLL<CR>"
endif

" function CiderVinegar() {{{1
function! CiderVinegar()
  let l:callerbufnr = bufnr('%')
  let l:folder = expand('%:h')
  let l:filename = expand('%:t')

  if expand('%') !=# ''
    execute 'e ' . l:folder
    execute "call search('".l:filename."', 'cW')"
    let l:dokeymaps = 1
  else
    execute "e ."
    let l:dokeymaps = 0
  endif

  if l:dokeymaps
    call CiderVinegarKeymaps(l:callerbufnr)
    " after opening split, switch nerdtree back to the buffer it was called from
    execute "nnoremap <buffer> " . g:NERDTreeMapOpenVSplit . " :call nerdtree#ui_glue#invokeKeyMap('" . g:NERDTreeMapOpenVSplit . "')<CR><C-w>p:b".l:callerbufnr."<CR><C-w>p"
    execute "nnoremap <buffer> " . g:NERDTreeMapOpenSplit . " :call nerdtree#ui_glue#invokeKeyMap('" . g:NERDTreeMapOpenSplit . "')<CR><C-w>p:b".l:callerbufnr."<CR><C-w>p"
    " TODO: add maps for nerd tree preview; it keeps opening new splits, need
    " to close the other one first
  endif

  " fix '.' buffers from hanging around
  if bufnr("^.$") != -1
    execute "bwipe" . bufnr("^.$")
  endif

  set nobuflisted
endfunction

" function CiderVinegarKeymaps(callerbufnr) {{{1
function! CiderVinegarKeymaps(callerbufnr)
  execute "nnoremap <buffer> q :b".a:callerbufnr."<CR>"
  if exists("g:CiderVinegarToggle")
    execute "nnoremap <buffer> " . g:CiderVinegarToggle . " :b".a:callerbufnr."<CR>:CiderVinegar<CR>"
  endif
  if exists("g:CiderVinegarToggleBuffers")
    execute "nnoremap <buffer> " . g:CiderVinegarToggleBuffers . " :b".a:callerbufnr."<CR>:CiderVinegarBuffers<CR>"
  endif
  if exists("g:CiderVinegarToggleQF")
    execute "nnoremap <buffer> " . g:CiderVinegarToggleQF . " :b".a:callerbufnr."<CR>:CiderVinegarQF<CR>"
  endif
  if exists("g:CiderVinegarToggleLL")
    execute "nnoremap <buffer> " . g:CiderVinegarToggleLL . " :b".a:callerbufnr."<CR>:CiderVinegarLL<CR>"
  endif
endfunction

" function CiderVinegarBuffers() {{{1
function! CiderVinegarBuffers()
  let l:callerbufnr = bufnr('%')
  execute "BuffergatorOpen"
  call CiderVinegarKeymaps(l:callerbufnr)
endfunction

" function CiderVinegarToggleList() {{{1
" with help from:
" http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! CiderVinegarToggleList(bufname, pfx)
  let buflist = CiderVinegarGetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif

  " make qf replace current window, close qf when select item
  let l:callerwinnr = winnr()
  let l:callerbufnr = bufnr("%")
  exec(a:pfx.'open')
  let qfwinnr = winnr()
  execute l:callerwinnr . " wincmd w"
  execute "buffer " . winbufnr(qfwinnr)
  execute qfwinnr . "wincmd c"
  nnoremap <buffer> <CR> <CR>:cclose<CR>
  " TODO add keymaps to open qf items in splits?

  call CiderVinegarKeymaps(l:callerbufnr)

  " if there are two windows, open qf item in current window, reopen other window (vert split only)
  " TODO make this work for horizontal splits too
  if winnr("$") == 2
    if winnr() == 1
      execute "nnoremap <buffer> <CR> <CR>:cclose<CR>:vertical split " . bufname(winbufnr(2)) . "<CR>:wincmd p<CR>"
    elseif winnr() == 2
      execute "nnoremap <buffer> <CR> <CR>:cclose<CR>:topleft vertical split " . bufname(winbufnr(1)) . "<CR>:wincmd p<CR>"
    endif
  endif

endfunction

" function CiderVinegarGetBufferList() {{{1
function! CiderVinegarGetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction
