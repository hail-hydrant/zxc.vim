" https://vi.stackexchange.com/questions/19919/how-can-i-log-debug-messages-without-blocking/19921#19921        

" Add debug messages to DebugList.
func logger#Log(msg)
    if exists("g:DebugList")
        call add(g:DebugList, strftime("%H:%M:%S") . " | " . a:msg)
    endif
endfunc

" Print debug messages in DebugList
func logger#PrintDebug()
    if exists("g:DebugList")
        for ln in g:DebugList
            echo "- " . ln
        endfor
    endif
endfunc

" Write DebugList to log file based on g:zxc_winame which is unique to each
" window.
func logger#WriteLog()
    if exists('g:zxc_winame')
        let filename = "./log/" .. g:zxc_winame .. "_debug.log"
        call writefile(g:DebugList, filename)
    else
        echom "No window name"
    endif
endfunc

" -- Commands
command PrintDebug call logger#PrintDebug()
command WriteDebug call logger#WriteLog()
