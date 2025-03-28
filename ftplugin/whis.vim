if !check_session#Check() && exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" Description:
"       View history of a single session.
"
" Syntax:
"       id | scheme | host
"
" Steps:
"        1. Find id
"        2. Build file name, current_dir/history/$id/websocket/history.wsess
"        3. Close previous wsess, wreq and wres buffers.
"        4. Open history.wsess in vert split

func s:ViewWsHistory()
    try
        let id = getline('.') ->split(" | ")[0]
    catch /.*/
        let fail_msg = "View| " .. v:exception
        call logger#Log(fail_msg)
        echom fail_msg
        return
    endtry

    " 2. Build file name
    let file = expand('%:h')
                \ .. "/" .. "history" ..
                \ "/" .. id ..
                \ "/" .. "websocket" ..
                \ "/" .. "history.wsess"

    " 3. delete previous buffers
    call delete#DeletebyExt("wreq")
    call delete#DeletebyExt("wres")
    call delete#DeletebyExt("wsess")

    " 4. Open history.wsess file in vert split
    silent execute 'vsp ' .. file
endfunc

setl autoread

command-buffer ViewWsHistory call s:ViewWsHistory()
nnoremap <buffer><silent><CR> :ViewWsHistory<CR>
