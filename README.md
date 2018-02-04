# Vim Cider Vinegar

A mini plugin that applies the philosophy of [vim-vinegar](https://github.com/tpope/vim-vinegar) and the [oil and vinegar vimcast](http://vimcasts.org/blog/2013/01/oil-and-vinegar-split-windows-and-project-drawer/) to [NERDTree](https://github.com/scrooloose/nerdtree) and [Buffergator](https://github.com/jeetsukumaran/vim-buffergator).

The functions `CiderVinegar` and `CiderVinegarBuffers` open a NERDTree buffer and a Buffergator buffer in the current window, respectively. Whenever this buffer is closed (by selecting a file for split-view, or quitting the window (q) or the toggle keymap), the window is returned to the buffer where you started.

## Suggested Keymaps

```vim
let g:CiderVinegarToggle = '<leader>e'
let g:CiderVinegarToggleBuffers = '<leader>b'
```

## Requirements

You must have both [NERDTree](https://github.com/scrooloose/nerdtree) and [Buffergator](https://github.com/jeetsukumaran/vim-buffergator) plugins installed. 

```vim
Plug 'scrooloose/NERDTree'
Plug 'jeetsukumaran/vim-buffergator'
```

Additionally, the following options must be set in your vimrc (otherwise Cider Vinegar will set them for you):

```vim
let g:NERDTreeHijackNetrw = 1
let g:NERDTreeQuitOnOpen = 1
let g:buffergator_viewport_split_policy = "N"
```

## Installation

```vim
Plug 'gabenespoli/vim-cider-vinegar'
```
