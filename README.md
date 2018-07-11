# Vim Cider Vinegar

A mini plugin that applies the philosophy of [vim-vinegar](https://github.com/tpope/vim-vinegar) and the [oil and vinegar vimcast](http://vimcasts.org/blog/2013/01/oil-and-vinegar-split-windows-and-project-drawer/) to [NERDTree](https://github.com/scrooloose/nerdtree), [Buffergator](https://github.com/jeetsukumaran/vim-buffergator), and the Quickfix and Location Lists.

## Installation

Use your favourite plugin manager like [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'gabenespoli/vim-cider-vinegar'
```

Enable the plugin by adding these to your vimrc:

```vim
let g:CiderEnableNERDTree = 1
let g:CiderEnableBuffergator = 1
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

## Commands and Keymaps

The commands below open their respective buffers in the current window, replacing the buffer that was there before. Selecting a file from this list will open it in the current window. If a file is selected for split-view or if the window is closed (using `q`), the window is returned to the buffer where you started.

| Command                | Buffer Opened | Suggested Keymap |
| ---------------------- | ------------- | ---------------- |
| `:Cider`               | NERDTree      | `-`              |
| `:CiderBuffers`        | Buffergator   | `=`              |
| `:CiderQF`             | Quickfix List | `<leader>q`      |
| `:CiderLL`             | Location List | `<leader>l`      |

Copy the following to your vimrc to use the suggested keymaps.

```vim
let g:CiderToggleNERDTree = '-'
let g:CiderToggleBuffergator = '='
let g:CiderToggleQF = '<leader>q'
let g:CiderToggleLL = '<leader>l'
```

Note that these keymaps act as toggles, so pressing `-` in a Cider NERDTree window will close it, instead of the vim-vinegar behaviour of continuing up the directory tree. To turn this off, add `let g:CiderWithVinegar = 0` to your vimrc.
