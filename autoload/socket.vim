func socket#Connect(module_name)
    let sock_name = "/tmp/" .. g:session_name .. "/" .. a:module_name .. ".sock"
    let sock = "unix:" .. sock_name
    let chan = ch_open(sock)
    call logger#Log("sock connected")
    call ch_setoptions(chan, {"callback": "s:Default", "timeout": g:timeout})
    return chan
endfunc

" Send close message to binary.
func socket#Close()
    if &ft == "toml"
        return
    endif
    let tosend = "Close"
    call ch_sendexpr(g:channel, tosend)
    call logger#Log("Sock Closed")
endfunc

func s:Default(chan, msg)
    call logger#Log("Recv| " .. json_encode(a:msg))
    if close_msg#Check(a:msg)
        qa!
    endif
    if storage#Add(a:msg)
        return
    endif
    call HandleMsg(a:msg)
endfunc
