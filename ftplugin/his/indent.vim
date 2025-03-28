if !check_session#Check()
    finish
endif

call system("which column")
let g:has_column = !v:shell_error

func s:Indent()
    if !g:has_column
        return
    endif
    set modifiable
    " mark cursor position
    normal! mt
    execute ':%!column -t -s "|" -o "|"'
    set write
    silent execute 'write'
    " jump back
    normal! `t
    set nowrite
    set nomodifiable
endfunc

command-buffer HistoryIndent call s:Indent()
