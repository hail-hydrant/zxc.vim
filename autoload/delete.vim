" Description:
"       Delete all buffers in current tab with a given extension.
" 
" Args:
"       extension : String
"
" Steps:
"       1. Get buffer list.
"       2. Loop through buffer list and check if the buffer name contains
"          given extension.
"       3. If yes, delete the buffer.

func delete#DeletebyExt(extension)
    for buf in tabpagebuflist(tabpagenr())
        if bufname(buf) ->fnamemodify(':e') == a:extension
            execute 'bdelete! ' . buf
        endif
    endfor
endfunc

" Description:
"       Same as above, but with exception file.
"
" Args:
"       extension: String
"       exception: String

func delete#DeletebyExtWithException(extension, exception)
    for buf in tabpagebuflist(tabpagenr())
        let bname = bufname(buf)
        let fname = bname ->fnamemodify(':t')
        if fname != a:exception && bname ->fnamemodify(':e') == a:extension
            execute 'bdelete! ' . buf
        endif
    endfor
endfunc
