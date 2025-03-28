" Description:
"       Setup a http request repeater tab.
"
" Argument:
"       {   "file": r-id/req,
"           "server_info": {
"               "scheme": b:scheme,
"               "host": b:host
"               "sni": b:sni (only for https and optional) } }
"
" Steps:
"       1. Get Request File.
"       2. Open request and response files.
"       3. Set b:scheme and b:host.

func repeater_helper#request#Repeat(query)
    call logger#Log("Repeat| " .. json_encode(a:query))

    let src_req = a:query.file
    let res = fnamemodify(src_req, ":r") .. ".res"
    call tab#add()

    " 2. Open request and response
    silent execute 'e' src_req
    silent execute 'vsp' res
    silent execute 'wincmd w'
    silent execute 'horizontal wincmd ='

    call SetBufVar(a:query.server_info)
endfunc

" Description:
"       Send request info to binary.
"
" Data Sent:
"       { "Send": {
"           "file": expand('%'),
"           "update": b:update,
"           "server_info": {
"               "http": v:true
"               "host": b:host,
"               "sni": b:sni    } } }
"
" Steps:
"       1. Write the file.
"       2. Build tosend dictionary.
"       3. Add update if b:update exists and is not v:true
"       4. Send to binary and get response.
"       5. Reload req and res
"       6. Get response time and size.
"       7. Set status line. time + size or echo error.

func repeater_helper#request#Send()
    silent execute 'write!'
    let tosend = {}

    let tosend["Send"] = ServerInfo()
    let tosend["Send"]["file"] = expand('%')

    " 3. Check if frame should be updated.
    call add_update#Add(tosend["Send"])
    call logger#Log("Sent| " .. json_encode(tosend))

    " 4. Send to binary and get response
    let result = ch_evalexpr(g:channel, tosend)
    call logger#Log("Recv| " .. string(result))

    if empty(result)
        return
    endif

    " 5. Reload req and res
    silent windo e!

    " 6. Get response time and size
    if result ->has_key("time")
        let t:time = result.time .. " ms"
        let t:size = result.size .. " bytes"
    elseif result ->has_key("error")
        let t:time = result.error
        let t:size = 0
        let fail_msg =  "Error| " .. result.error
        call logger#Log(fail_msg)
        echom fail_msg
    else
        let fail_msg =  "Recv Error| " .. string(result)
        call logger#Log(fail_msg)
        echom fail_msg
        return
    endif

    " 7. Set status line. time + size or error
    setl statusline=\>\ %{t:time}
    setl statusline+=%=
    setl statusline+=\>\ %{t:size}
endfunc
