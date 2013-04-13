" pathogen
call pathogen#infect()
syntax on
filetype plugin indent on

" compatibility
set nocompatible
set modelines=0

" usability
set mouse=a
set encoding=utf-8
set scrolloff=3
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set relativenumber
set undofile

" remap leader. default "\"
let mapleader = ","

" search
" user pcre
nnoremap / /\v
vnoremap / /\v

set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch

nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

" tabs and indentation
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set autoindent
set cindent

" wrapping
set wrap
set formatoptions=qrn1

" show invisible characters
set list
set listchars=trail:⋅,nbsp:⋅,tab:▸\ ,eol:¬

" use hjkl
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" map F1 to ESC
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" map ; to :
nnoremap ; :

" colorscheme
set t_Co=256
set background=dark
colorscheme smyck

" gui

if has("gui_running")
    if has("gui_gtk2")
        set guifont=Bitstream\ Vera\ Sans\ Mono\ 9
    elseif has("gui_win32")
        set guifont=Consolas:h11:cANSI
    endif

    "set guioptions-=m   " remove menubar
    set guioptions-=T   " remove toolbar
    set guioptions-=r   " remove right-hand scrollbar
    set linespace=1
else
endif

" hotkeys

" strip all trailing spaces in the current line
noremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" ack
nnoremap <leader>a :Ack

" fold tag
nnoremap <leader>ft Vatzf

" re-hardwrap paragraphs of text
nnoremap <leader>q gqip

" reselect pasted text
nnoremap <leader>v V`]

" open ~/.vimrc for editing
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<cr>

" map jj to exit back to normal mode
inoremap jj <ESC>

" windows
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

