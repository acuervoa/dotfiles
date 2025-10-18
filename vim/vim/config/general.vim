" =============================
" => General Settings
" =============================
set mouse=a
set number
set relativenumber
set history=1000

" Habilitar filetypes, plugins e indentación
filetype plugin on
filetype indent on

" Auto-read: actualizar el archivo si cambia externamente
set autoread
au FocusGained,BufEnter * silent! checktime
set clipboard=unnamedplus

" Definir mapleader
let mapleader = " "

" Guardado rápido
nmap <leader>w :w!<CR>
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" ============================
" => VIM User Interface
" ============================
set so=7
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

set termguicolors
set wildmenu
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

set ruler
set cmdheight=1
set updatetime=300
set shortmess+=c
set hid
set backspace=eol,start,indent

" Opciones de búsqueda
set ignorecase
set smartcase
set hlsearch
set incsearch

" Optimización visual y de rendimiento
set lazyredraw
set magic
set showmatch
set mat=2
set noerrorbells
set novisualbell
set t_vb=
set tm=500

if has("gui_macvim")
    autocmd GUIEnter * set vb t_vb=
endif

" Agrega margen para folds
set foldcolumn=1

" =========================
" => Colors and Fonts
" =========================
syntax enable
set regexpengine=0
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

try
    colorscheme desert
catch
endtry

set background=dark

if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

set encoding=utf8
set ffs=unix,dos,mac

" =========================
" => Files, Backups and Undo
" =========================
set nobackup
set nowb
set noswapfile

" ===============================
" => Text, Tab and Indent Related
" ===============================
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=500
set autoindent
set smartindent
set wrap
