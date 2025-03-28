" Description:
"       Map character to codec name
"
" Args:
"       enc : String
"
" Returns:
"       string

func s:ToCodec(enc)
    if a:enc == "b"
        return "Base64"
    elseif a:enc == "u"
        return "Url"
    elseif a:enc == "ku"
        return "UrlAll"
    endif
    return ""
endfunc

" Description:
"       Encode/decode string. Uses register "x".
"
" Args:
"       action : String
"
" Steps:
"       1. Get string from register "x"
"       2. Set tosend dict key
"               if a:action[0] == "d", decode.
"               Default encode
"       3. Build tosend dict value, {"codec": codec, "data": content}
"       4. Send tosend dict to channel and get result from channel by calling
"       ch_evalexpr()
"       5. Insert result.

func s:EnDeCode(action)
    " 1. Get string from register "x"
    let content = getreg("x")

    " 2. Set tosend dict key
    let key = "Encode"
    if a:action[0] == "d"
        let key = "Decode"
    endif

    " 3. Build tosend dict value
    let codec = s:ToCodec(a:action[1 : ])
    let tosend = {}
    let value = {"codec": codec, "data": content}
    let tosend[key] = value
    call logger#Log("Codec Sent| " .. json_encode(tosend))
    try
        " 4. Send tosend dict to channel and get result from channel
        let recv_buf = ch_evalexpr(g:channel, tosend)
        let result = get(recv_buf, "result")
        call logger#Log("Codec Recv| " .. json_encode(recv_buf))
        " 5. Insert result.
        silent execute 'norm! i' .. result
    catch /.*/
        let fail_msg = "codec| " .. string(tosend) .. " | " .. v:exception
        call logger#Log(fail_msg)
        echom fail_msg
    endtry
endfunc

command EBase64 call s:EnDeCode("eb")
command EUrl call s:EnDeCode("eu")
command EUrlAll call s:EnDeCode("eku")
command DBase64 call s:EnDeCode("db")
command DUrl call s:EnDeCode("du")
command DUrlAll call s:EnDeCode("dku")
