" ============================
" => Visual Mode Mappings
" ============================
vnoremap <silent> * :<C-u>call VisualSelection('','')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('','')<CR>?<C-R>=@/<CR><CR>

" ===========================================
" => Moving Around, Tabs, Windows and Buffers
" ===========================================
" Desactivar resaltado de búsqueda
map <silent> <leader><CR> :noh<CR>

" Navegar entre ventanas con Ctrl+h/j/k/l
map <C-h> <C-W>h
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l

" Gestión de buffers y pesatañas
map <leader>bd :Bclose<BR>:tabclose<CR>gT
map <leader>ba :bufdo bd<CR>
map <leader>l :bnext<CR>
map <leader>h :bprevious<CR>

map <leader>tn :tabnew<CR>
map <leader>to :tabonly<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext<CR>

let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Abrir nueva pestaña con el directorio del archivo actual
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<CR>/
" Cambiar el directorio de trabajo al del archivo abierto
map <leader>cd :cd %p:h<CR>:pwd<CR>

try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

" Regresar a la última posición al abrir un archivo
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" ======================
" => Status Line
" ======================
set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c


" ======================
" => Editing Mappings
" ======================
" Remap 0 para ir al primer carácter no blanco
map 0 ^
" Mover líneas de texto con Alt+[j,k]
nmap <M-j> mz:m+<CR>`z
nmap <M-k> mz:m-2<CR>`z
vmap <M-j> :m'>+<CR>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<CR>`<my`<mzgv`yo`z

if has("mac") || has("macunix")
    nmap <D-j> <M-j>
    nmap <D-k> <M-k>
    vmap <D-j> <M-j>
    vmap <D-j> <M-j>
endif

" ==============================
" => Spell Checking Mapping
" ==============================
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

" =============================
" => Miscellaneous Mappings
" =============================
" Eliminar ^M (retorno de carro) de Windows
noremap <Leader>m mmHmt:%s/<C-V><CR>//ge<CR>'tzt'm

" Abrir rápidamente un buffer para scribble
map <leader>q :e ~/buffer<CR>
map <leader>x :e ~/buffer.md<CR>

" Toggle modo paste
map <leader>pp :setlocal paste!<CR>

" Mover bloques en modo visual
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '>-2<CR>gv=gv

" Ajustar números relativos en modo inserción
autocmd InsertEnter * set norelativenumber
autocmd InsertLeave * set relativenumber

" Salir de inserción con "jj"
inoremap jj <Esc>


" ====================================
" => Plugins especificos de navegacion
" ====================================
" NERDTree: Toggle con <leader>n
nnoremap <leader>n :NERDTreeToggle<CR>
