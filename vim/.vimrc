" plugin
call plug#begin()
Plug 'arcticicestudio/nord-vim'    
Plug 'vim-airline/vim-airline'
call plug#end()

" theme
colorscheme nord

" key binding

" change space as leader
let mapleader = " "

" insert mode
" exit insert mode when press jj 
inoremap jj <Esc>

" normal mode
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :q!<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>x :wq<CR>

" visual mode
vnoremap <Leader>w <Esc>

" command line mode
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-h> <Home>
cnoremap <C-l> <End>
cnoremap <C-c> <Esc>

" basic configuration
syntax on
filetype plugin indent on
set encoding=utf-8
set fileencodings=utf-8,usc-bom,GB2312,big5
set nocompatible
set cursorline
set wildmenu
set nu
set rnu
nnoremap <Leader>r :set rnu!<CR>
set wrap
set ruler
" use system  clipborad
set clipboard=unnamedplus

set shiftwidth=4
set expandtab
set softtabstop=4
set shiftwidth=4
" search
set ic
set hlsearch
nnoremap <Leader>s :set hlsearch!<CR>
" command mode complete
set wildmenu
set wildmode=longest:list,full
