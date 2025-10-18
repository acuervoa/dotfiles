" =======================
" => Helper Functions
" =======================
" Devuelve un indicador si el modo paste está activo
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" Comando para cerrar buffers sin cerrar la ventana
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")
    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif
    if bufnr("%") == l:currentBufNum
        new
    endif
    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" Función para alimentar comandos en la línea de comandos
function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

" Función para trabajar con selecciones visuales (por búsqueda o reemplazo)
function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' ")
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Al final, intenta cargar el esquema gruvbox (para integrarlo con lightline, por ejemplo)
try
    colorscheme gruvbox
catch
endtry

