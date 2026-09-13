" Display
set number
set linebreak
set breakindent
set showbreak=+++
set scrolloff=5
set showmatch
set visualbell

" 100-column guide without forced wrapping
set textwidth=0
set colorcolumn=100

" Search
set ignorecase
set smartcase
set incsearch
set hlsearch

" Indentation
set expandtab
set shiftwidth=2
set softtabstop=-1
set autoindent

" Editing
set backspace=indent,eol,start
set hidden
set undofile
set fixendofline

" Command completion
set wildmenu
set wildmode=longest:full,full

" Show whitespace
set list
set listchars=tab:→\ ,space:·,trail:·,eol:↲

" Status line
set laststatus=2
set statusline=%f
set statusline+=%m
set statusline+=%r
set statusline+=%{&endofline?'':'[noeol]'}
set statusline+=\ [%{&fileformat=='unix'?'LF':&fileformat=='dos'?'CRLF':'CR'}]
set statusline+=%=
set statusline+=%y
set statusline+=\ %l/%L
set statusline+=\ col:%c
set statusline+=\ %p%%

" Subtle status line
highlight StatusLine cterm=NONE ctermfg=7 ctermbg=8
highlight StatusLineNC cterm=NONE ctermfg=8 ctermbg=0

" Filetype support
filetype plugin indent on
syntax on
