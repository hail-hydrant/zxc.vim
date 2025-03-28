let s:Buf = []

func storage#Flush()
    if empty(s:Buf)
        return
    endif
    for entry in s:Buf
        call HandleMsg(entry)
    endfor
    let s:Buf = []
    call logger#Log("storage| flush")
endfunc


func storage#Add(msg)
    if win_gettype() ==# 'popup'
        call logger#Log("storage| add")
        call add(s:Buf, a:msg)
        return v:true
    endif
    return v:false
endfunc
