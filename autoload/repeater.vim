if exists('g:did_session')
    finish
endif
let g:did_session = 1
let g:channel = socket#Connect("repeater")

func s:Send()
    if &ft == 'req'
        call repeater_helper#request#Send()
    elseif &ft == 'wreq'
        call repeater_helper#websocket#Send()
    else
        call logger#Log("unknown ft| " .. &ft)
    endif
endfunc

" Argument:
"       {   "file": r-id/req,
"           "server_info": {
"               "scheme": b:scheme,
"               "host": b:host
"               "sni": b:sni (only for https and optional) } }
"
"
" Steps:
"   1. Get the value of "file" key from message and check extension
"   2. Call appropriate function

func HandleMsg(msg)
    let ext = fnamemodify(a:msg['file'], ':e')
    if ext == 'req'
        call repeater_helper#request#Repeat(a:msg)
    elseif ext == 'wreq'
        call repeater_helper#websocket#Repeat(a:msg)
    else
        call logger#Log("unknown ext| " .. ext)
    endif
endfunc

func SetBufVar(info)
    let b:host = a:info.host
    if a:info ->has_key('http')
        let b:scheme = "http"
    else
        let b:scheme = "https"
    endif
    if a:info ->has_key('sni')
        let b:sni = a:info.sni
    endif
    call SetHostStatusLine()
endfunc

command RepeaterSend call s:Send()
