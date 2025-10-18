" =======================
" => Lightline Configuration
" =======================
" Se asume que termguicolors ya está activado en general.vim
if exists('g:lightline')
  let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'percent' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'filename' ] ],
      \   'right': [ ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help" ? "" : &readonly ? "🔒" : ""}',
      \   'modified': '%{&filetype=="help" ? "" : &modified ? "+" : &modifiable ? "" : "-"}',
      \   'fugitive': '%{exists("*FugitiveHead") && strlen(FugitiveHead()) ? " ".FugitiveHead() : ""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help" && &readonly)',
      \   'modified': '(&filetype!="help" && (&modified || !&modifiable))',
      \   'fugitive': '(exists("*FugitiveHead") && strlen(FugitiveHead()))'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }
endif

