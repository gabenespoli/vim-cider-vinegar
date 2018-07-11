" First some checks {{{1
if exists('g:CiderEnableNERDTree') && g:CiderEnableNERDTree == 1
  if g:NERDTreeHijackNetrw != 1
    let g:NERDTreeHijackNetrw = 1
    echomsg 'CiderVinegar set g:NERDTreeHijackNetrw to 1.'
  endif
  if g:NERDTreeQuitOnOpen != 1
    let g:NERDTreeQuitOnOpen = 1
    echomsg 'CiderVinegar set g:NERDTreeQuitOnOpen to 1.'
  endif
endif

if exists('g:CiderEnableBuffergator') && g:CiderEnableBuffergator == 1
  if g:buffergator_viewport_split_policy !=# 'N'
    let g:buffergator_viewport_split_policy = 'N'
    echomsg 'CiderVinegar set g:buffergator_viewport_split_policy to N.'
  endif
endif

" Commands and Keymaps {{{1
command! Cider        call CiderVinegarNERDTree()
command! CiderBuffers call CiderVinegarBuffergator()
command! CiderQF      call CiderVinegarToggleList("QuickFix List", "c")
command! CiderLL      call CiderVinegarToggleList("Location List", "l")

if exists('g:CiderToggleNERDTree')
      \ && exists('g:CiderEnableNERDTree')
      \ && g:CiderEnableNERDTree == 1
  execute 'nnoremap ' . g:CiderToggleNERDTree .
        \ ' :call CiderVinegarNERDTree()<CR>'
endif

if exists('g:CiderToggleBuffergator') 
      \ && exists('g:CiderEnableBuffergator') 
      \ && g:CiderEnableBuffergator == 1
  execute 'nnoremap ' . g:CiderToggleBuffergator .
        \ ' :call CiderVinegarBuffergator()<CR>'
endif

if exists('g:CiderToggleQF')
  execute 'nnoremap ' . g:CiderToggleQF .
        \ ' :call CiderVinegarToggleList("QuickFix List", "c")<CR>'
endif

if exists('g:CiderToggleLL')
  execute 'nnoremap ' . g:CiderToggleLL .
        \ ' :call CiderVinegarToggleList("Location List", "l")<CR>'
endif

" function CiderVinegarNERDTree() {{{1
function! CiderVinegarNERDTree()
  let l:callerbufnr = bufnr('%')
  let l:folder = expand('%:h')
  let l:filename = expand('%:t')

  if expand('%') !=? ''
    execute 'e ' . l:folder
    execute "call search('".l:filename."', 'cW')"
    let l:dokeymaps = 1
  else
    execute 'e .'
    let l:dokeymaps = 0
  endif

  if l:dokeymaps
    call CiderVinegarKeymaps(l:callerbufnr, 'NERDTree')
    " after opening split, switch nerdtree back to the buffer it was called from
    execute 'nnoremap <buffer> ' . g:NERDTreeMapOpenVSplit . 
          \ " :call nerdtree#ui_glue#invokeKeyMap('" . g:NERDTreeMapOpenVSplit .
          \ "')<CR><C-w>p:b".l:callerbufnr.'<CR><C-w>p'
    execute 'nnoremap <buffer> ' . g:NERDTreeMapOpenSplit .
          \ " :call nerdtree#ui_glue#invokeKeyMap('" . g:NERDTreeMapOpenSplit .
          \ "')<CR><C-w>p:b".l:callerbufnr.'<CR><C-w>p'
    " TODO: add maps for nerd tree preview; it keeps opening new splits, need
    " to close the other one first
  endif

  " fix '.' buffers from hanging around
  if bufnr('^.$') != -1
    execute 'bwipe' . bufnr('^.$')
  endif

  set nobuflisted
endfunction

" function CiderVinegarKeymaps(callerbufnr, type) {{{1
function! CiderVinegarKeymaps(callerbufnr, type)
  " use same map to toggle back
  if exists('g:CiderQuitMap')
    execute 'nnoremap <silent> <buffer> ' . g:CiderQuitMap . 
          \ ' :b' . a:callerbufnr . '<CR>'
  endif

  if a:type ==? 'NERDTree' && exists('g:CiderToggleNERDTree')
        \ && (!exists('g:CiderWithVinegar') || g:CiderWithVinegar != 0)
    execute 'nnoremap <silent> <buffer> ' . g:CiderToggleNERDTree .
          \ ' :b' . a:callerbufnr . '<CR>'

  elseif a:type ==? 'Buffergator' && exists('g:CiderToggleBuffergator')
    execute 'nnoremap <silent> <buffer> ' . g:CiderToggleBuffergator .
          \ ' :b'.a:callerbufnr.'<CR>'

  elseif a:type ==? 'c' && exists('g:CiderToggleQF')
    execute 'nnoremap <silent> <buffer> ' . g:CiderToggleQF .
          \ ' :b'.a:callerbufnr.'<CR>'

  elseif a:type ==? 'l' && exists('g:CiderToggleLL')
    execute 'nnoremap <silent> <buffer> ' . g:CiderToggleLL .
          \ ' :b'.a:callerbufnr.'<CR>'
  endif
endfunction

" function CiderVinegarBuffergator() {{{1
function! CiderVinegarBuffergator()
  let l:callerbufnr = bufnr('%')
  execute 'BuffergatorOpen'
  call CiderVinegarKeymaps(l:callerbufnr, 'Buffergator')
endfunction

" function CiderVinegarListIsOpen() {{{1
" http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! CiderVinegarListIsOpen(list)
  if a:list ==? 'QuickFix List' || 
        \ a:list ==? 'qf' ||
        \ a:list ==? 'c'
    let l:bufname = 'QuickFix List'
  elseif a:list ==? 'Location List' ||
    \ a:list ==? 'll' ||
    \ a:list ==? 'l'
    let l:bufname = 'Location List'
  endif
  let l:buflist = CiderVinegarGetBufferList()
  for l:bufnr in map(filter(split(l:buflist, '\n'),
        \ 'v:val =~ "'.l:bufname.'"'), 
        \ 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(l:bufnr) != -1
      return 1
    endif
  endfor
endfunction

" function CiderVinegarToggleList() {{{1
function! CiderVinegarToggleList(bufname, pfx)
  if CiderVinegarListIsOpen(a:pfx)
    execute a:pfx . 'close'
    return
  endif

  " make qf replace current window, close qf when select item
  let l:callerwinnr = winnr()
  let l:callerbufnr = bufnr('%')
  exec(a:pfx.'open')
  let qfwinnr = winnr()
  execute l:callerwinnr . ' wincmd w'
  execute 'buffer ' . winbufnr(qfwinnr)
  execute qfwinnr . 'wincmd c'
  nnoremap <buffer> <CR> <CR>:cclose<CR>
  " TODO add keymaps to open qf items in splits?

  call CiderVinegarKeymaps(l:callerbufnr, a:pfx)

  " if there are two windows, open qf item in current window, reopen other window (vert split only)
  " TODO make this work for horizontal splits too
  if winnr('$') == 2
    if winnr() == 1
      execute 'nnoremap <buffer> <CR> <CR>:cclose<CR>:vertical split ' . bufname(winbufnr(2)) . '<CR>:wincmd p<CR>'
    elseif winnr() == 2
      execute 'nnoremap <buffer> <CR> <CR>:cclose<CR>:topleft vertical split ' . bufname(winbufnr(1)) . '<CR>:wincmd p<CR>'
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
