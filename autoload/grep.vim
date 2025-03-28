if &grepprg == "grep -n $* /dev/null"
    set grepprg=grep\ -n
endif

func grep#Grep(ft, ...)
    let s:title = a:ft .. "| " .. join(a:000, ' ')
    let query = join([&grepprg] + a:000, ' ')  .. " ./history/**/*."
    if (a:ft == "req") || (a:ft == "res")
        let query = query .. a:ft
    elseif a:ft == "b"
        let query = query .. "{req,res}"
    endif
    return system(query)
endfunc

augroup quickfix
    au!
    au QuickFixCmdPost cgetexpr cwindow
    au QuickFixCmdPost lgetexpr lwindow
augroup END
