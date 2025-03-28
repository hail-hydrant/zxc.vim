" Check if close message
func close_msg#Check(msg)
    let tocheck = {"Action": "Close"}
    if a:msg == tocheck
        return v:true
    endif
    return v:false
endfunc

