" First some checks {{{1
if g:NERDTreeHijackNetrw != 1
  let g:NERDTreeHijackNetrw = 1
  echomsg "CiderVinegar set g:NERDTreeHijackNetrw to 1."
endif
if g:NERDTreeQuitOnOpen != 1
  let g:NERDTreeQuitOnOpen = 1
  echomsg "CiderVinegar set g:NERDTreeQuitOnOpen to 1."
endif
if g:buffergator_viewport_split_policy != "N"
  let g:buffergator_viewport_split_policy = "N"
  echomsg "CiderVinegar set g:buffergator_viewport_split_policy to N."
endif

" Commands and Keymaps {{{1
command! CiderVinegar call CiderVinegar()
command! CiderVinegarBuffers call CiderVinegarBuffers()

if exists("g:CiderVinegarToggle")
  execute "nnoremap " . g:CiderVinegarToggle . " :CiderVinegar<CR>"
endif
if exists("g:CiderVinegarToggleBuffers")
  execute "nnoremap " . g:CiderVinegarToggleBuffers . " :CiderVinegarBuffers<CR>"
endif

" function CiderVinegar() {{{1
function! CiderVinegar()
  let l:callerbufnr = bufnr('%')

  if expand('%') != ''
    execute "e " . expand('%:h')
    execute "call search('".expand('%:t')."', 'cW')"
    let l:dokeymaps = 1
  else
    execute "e ."
    let l:dokeymaps = 0
  endif

  if l:dokeymaps
    " after opening split, switch nerdtree back to the buffer it was called from
    execute "nnoremap <buffer> q :b".l:callerbufnr."<CR>"
    if exists("g:CiderVinegarToggle")
      execute "nnoremap <buffer> " . g:CiderVinegarToggle . " :b".l:callerbufnr."<CR>"
    endif
    if exists("g:CiderVinegarToggleBuffers")
      execute "nnoremap <buffer> " . g:CiderVinegarToggleBuffers . " :b".l:callerbufnr."<CR>:CiderVinegarBuffers<CR>"
    endif
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

" function CiderVinegarBuffers() {{{1
function! CiderVinegarBuffers()
  let l:callerbufnr = bufnr('%')
  execute "BuffergatorOpen"
  execute "nnoremap <buffer> q :b".l:callerbufnr."<CR>"
  if exists("g:CiderVinegarToggle")
    execute "nnoremap <buffer> " . g:CiderVinegarToggle . " :b".l:callerbufnr."<CR>:CiderVinegar<CR>"
  endif
  if exists("g:CiderVinegarToggleBuffers")
    execute "nnoremap <buffer> " . g:CiderVinegarToggleBuffers . " :b".l:callerbufnr."<CR>"
  endif
endfunction
