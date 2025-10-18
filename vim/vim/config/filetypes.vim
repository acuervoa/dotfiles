" =======================
" => FileTypes & Autocommands
" =======================
filetype plugin indent on

" Limpiar espacios finales al guardar para varios tipos de archivo
autocmd BufWritePre *.txt,*.js,*.jsx,*.ts,*.tsx,*.py,*.php,*.html,*.css,*.rs,*.go,*.wiki,*.sh,*.coffee call CleanExtraSpaces()

" Regresar al último cursor al abrir un archivo
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Configuración específica por filetype:
autocmd FileType python      setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType javascript,typescript setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType html,css    setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType php       setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType markdown  setlocal spell

