if !check_session#Check() && exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" Description:
"       Function to send ws request to repeater.
"
" Data Sent:
"       { 'to': "Repeater",
"         'file': expand('%') } }

func s:WsSendToRepeater()
    let info = {}
    let info["to"] = "Repeater"
    let info["file"] = expand('%')

    let tosend = {"Forward": info}
    call logger#Log("Send to Repeater| " .. string(tosend))
    call ch_sendexpr(g:channel, tosend)
endfunc

command-buffer WsSendToRepeater :call s:WsSendToRepeater()
