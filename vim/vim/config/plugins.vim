" =======================
" => Plugin Bootstrap y Declaraciones
" =======================
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" --- Configuración Base ---
Plug 'amix/vimrc'

" --- Navegación y Búsqueda ---
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'liuchengxu/vim-which-key'

" --- Explorador de archivos ---
Plug 'preservim/nerdtree'

" --- Status Line ---
Plug 'itchyny/lightline.vim'


" --- Lenguajes y Snippets ---
Plug 'mattn/emmet-vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'

" --- Integración con Git ---
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-rhubarb'

" --- Linting, Formateo y LSP ---
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch':'release'}

" --- Soporte para Lenguajes Específicos ---
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'StanAngeloff/php.vim'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go'
Plug 'plasticboy/vim-markdown'

" --- Depuración (Opcional) ---
Plug 'puremourning/vimspector'

" --- Temas y Colores ---
Plug 'morhetz/gruvbox'
Plug 'altercation/vim-colors-solarized'
Plug 'dracula/vim', { 'as': 'dracula' }

call plug#end()



" ======================
" Configuracion para fzf
" ======================
" Establece un layout que use el 40% de la ventana inferior para los resultados
let g:fzf_layout = { 'down': '40%' }

" Mapeo para abrir el buscador de archivos
nnoremap <C-p> :Files<CR>
" Mapeo para buscar entre los buffers abiertos
nnoremap <leader>b :Buffers<CR>


" ======================
" Configuracion basica de EasyMotin (usa los mapeos por defecto)
" ======================
" Por ejemplo, para saltar a inicios de paabras:
nmap <Leader><Leader>w <Plug>(easymotion-w)



" ======================
" Configuracion de vim-which-key
" ======================
" Timeout de la ventana emergente
let g:which_key_timeout = 1000

" ======================
" Emmet
" ======================
" Activa Emmet en modos normal e insert
let g:user_emmet_mode = 'a'
" Define la tecla lider para expandir abreviaturas
let g:user_emmet_leader_key = '<C-y>'


" ======================
" Fugitive
" ======================
noremap <leader>gs :Gstatus<CR>
noremap <leader>gc :Gcommit<CR>
noremap <leader>gp :Gpush<CR>
noremap <leader>gl :Glog<CR>
" rhubarb
noremap <leader>gb :GBrowse<CR>


 " ======================
 " Gitgutter
 " ======================
 let g:gitgutter_enabled=1
 nnoremap <leader>gd :GitGutterToggle<CR>

 " ======================
 " ALE
 " ======================
 let g:ale_linters_explicit = 1
 let g:ale_fix_on_save = 1
 let g:ale_completion_enabled = 1

if !exists('g:ale_linters')
    let g:ale_linters = {}
endif

if !exists('g:ale_fixers')
    let g:ale_fixers = {}
endif

 " Linters y Fixers
 let g:ale_linters['javascript'] = ['eslint']
let g:ale_fixers['javascript']=['prettier']
let g:ale_linters['typescript']=['tsserver']
let g:ale_fixers['typescript']=['prettier']

let g:ale_linters['python']=['flake8']
let g:ale_fixers['python']=['black']

let g:ale_linters['php'] = ['phpstan']
let g:ale_fixers['php']=['php_cs_fixer']

let g:ale_linters['rust'] = ['cargo']
let g:ale_fixers['rust'] = ['rustfmt']

let g:ale_linters['go'] = ['golint']
let g:ale_fixers['go'] = ['gofmt', 'goimports']


 " ======================
 " Viminspector
 " ======================
nnoremap <F5> :VimspectorContinue<CR>
nnoremap <F9> :VimspectorToggleBreakpoint<CR>
nnoremap <F8> :VimspectorStepOver<CR>
nnoremap <F7> :VimspectorStepInto<CR>

" ==========================
" => Coc.nvim Configuration
" ==========================
if exists('g:coc_global_extensions')
else
    let g:coc_global_extensions = ['coc-phpls', 'coc-tsserver', 'coc-pyright', 'coc-go']
endif

inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"


