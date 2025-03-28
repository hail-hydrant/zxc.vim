if !check_session#Check() || exists("b:did_ftplugin")
    finish
endif

let b:did_ftplugin = 1
let s:Max_host = 1
let s:Max_method = 1
let s:Max_size = 1
let s:Max_uri = 1
let s:timer_id = -1
let s:interval = 500
let s:threshold = 5000

" Description:
"       Get host and scheme from current line.
"
" Synatx:
"       id | method | status | size | scheme | host | Uri
"
" Steps:
"       1. Split line into list with | as delimiter.
"       2. scheme = line_list[4]
"       3. host = line_list[5]
"
" Returns:
"       [string, string]

func Get_Host_Scheme()
    return getline('.') ->split(' | ')[4:5] ->map('trim(v:val)')
endfunc

" Description:
"       Pad string to specified length.
"
" Args:
"       value : string
"       len   : integer
"
" Returns:
"       [string, integer]
"
" Steps:
"       1. If value is longer than len
"               return, value, value_length
"       2. Else
"           a. pad value with repeat(" ", len - value_length)
"           b. return, padded value, a:length

func s:Pad(value, len)
    let arglen = a:value ->len()
    if arglen > a:len
        let plen = arglen
        let pval = a:value
    else
        let plen = a:len
        let pval = a:value .. repeat(" ", a:len - arglen)
    endif
    return [pval, plen]
endfunc

" Description:
"       Insert http request into history file.
"
" Arg:
"       {    "Request": {
"               "id":1,
"               "method":"GET",
"               "http":true,
"               "host":"www.google.com",
"               "uri":"grobots.txt"     }   }
"
" Steps:
"       1. Check if line can be inserted, since setline() can only insert.
"           a. If index > lastline, insert (index - lastline) empty lines.
"           b. If no winfixbuf, no need to jump buffer since, '1bufdo!' in
"           HandleMsg would have made the his main buffer.
"       2. If msg has key 'http,
"           then,
"               scheme = "http " , extra space for indentation
"           else
"               scheme = "https"
"       3. Pad host, method, and uri with their respective max length.
"       4. Build line,
"           id | method | <statuscode> | <size> | scheme | host | uri |
"           <statuscode> = " " * 3
"           <size>       = " " * s:Max_size
"       5. Insert line on buffer 1

func s:Request(msg)
        let index = a:msg.id
        " 1. Check if line can be inserted
        if exists('&winfixbuf')
            let lastline = line("$", s:his_winid) + 1
        else
            let lastline = line('$') + 1
        endif
        if index > lastline
            for _ in range(index - lastline)
                call appendbufline(1, line('$'), '')
            endfor
        endif

        " 2. set scheme
        if has_key(a:msg, "http")
            let scheme = "http "
        else
            let scheme = "https"
        endif

        " 3. Method
        let [host, s:Max_host] = s:Pad(a:msg.host, s:Max_host)
        let [method, s:Max_method] = s:Pad(a:msg.method, s:Max_method)
        let [uri, s:Max_uri] = s:Pad(a:msg.uri, s:Max_uri)

        " 4. Build line
        let line = index
                    \ .. " | " .. method
                    \ .. " | " .. repeat(" ", 3)
                    \ .. " | " .. repeat(" ", s:Max_size)
                    \ .. " | " .. scheme
                    \ .. " | " .. host
                    \ .. " | " .. uri
                    \ .. " |"

        call setbufline(1, index, line)
endfunc

" Description:
"       Insert http response into history file.
"
" Arg:
"       {   "Response": {
"               "id": 0,
"               "status": "200",
"               "length":2000 }   }
"
" Steps:
"       1. Split line into list with | as delimiter.
"       2. Set status at index 2
"       3. Set length at index 3
"       4. Pad Content Length, i.e. lines[3]
"       5. Build line by joining list with " | "
"       6. Insert line on buffer 1.

func s:Response(msg)
    let lines = getbufoneline(1, a:msg.id) ->split(" | ")
    let lines[2] = a:msg.status
    let lines[3] = a:msg.length ->string()
    let [lines[3], s:Max_size] = s:Pad(lines[3], s:Max_size)
    let line = lines ->join(" | ")
    call setbufline(1, a:msg.id, line)
endfunc

" Steps:
"       1. Make history buffer modifiable 
"       2. If no winfixbuf, save previous buffer
"       4. Get message type, a:msg -> keys()[0]
"       5. If Request, call Request() with a:msg["Request"] as arg.
"       6. If Response, call Response() with a:msg["Response"] as arg.
"       7. If Action, check value of a:msg["Action"]
"           a. if wsview, tabe ws.view and jump to previous tab.
"           b. if Close, write history buffer and exit.
"       8. Set nomodifiable.
"       9. If no winfixbuf and if previous buffer exists and is !=1 restore
"       previous buffer.

func HandleMsg(msg)
    if exists('&winfixbuf')
        call win_execute(s:his_winid, 'setl modifiable')
    else
        let cbuf = bufnr("%")
        execute '1bufdo! setl modifiable'
    endif

    let htype = a:msg ->keys()[0]
    if htype == "Request"
        try
            call s:Request(a:msg[htype])
        catch /.*/
            let fail_msg = "Request error| " .. v:exception .. " | " .. string(a:msg)
            call logger#Log(fail_msg)
            echom fail_msg
        endtry
    elseif htype == "Response"
        try
            call s:Response(a:msg[htype])
        catch /.*/
            let fail_msg = "Response error| " .. v:exception .. " | " .. string(a:msg)
            call logger#Log(fail_msg)
            echom fail_msg
        endtry
    elseif htype == "Action"
        let value = a:msg[htype]
        if value == "wsview"
            silent execute 'tabe ws.whis'
            silent execute 'tabp'
        elseif value == "Close"
            if exists('&winfixbuf')
                call win_execute(s:his_winid, 'setl write')
                call win_execute(s:his_winid, 'write')
            else
                silent execute '1bufdo! setl write'
                silent execute '1bufdo! write'
            endif
            qall!
        endif
    endif

    if exists('&winfixbuf')
        call win_execute(s:his_winid, 'setl nomodifiable')
    else
        execute '1bufdo! setl nomodifiable'
        if exists('cbuf') && cbuf != 1
            execute 'buffer! ' . cbuf
        endif
    endif
endfunc

" Description:
"       Set timer to check if buffer is modified.
"
" Steps:
"       1. If timer is running, stop it
"       2. Start timer with interval s:interval

func s:Timer()
    if s:timer_id != -1
        call timer_stop(s:timer_id)
        let s:timer_id = -1
    endif
    let s:timer_id = timer_start(s:interval, 's:CheckMod')
endfunc

" Description:
"       Write file and reset timer if buffer is modified.

func s:CheckMod(timer_id)
    if getbufvar(1, "&modified")
        if exists('&winfixbuf')
            call win_execute(s:his_winid, 'setl write')
            call win_execute(s:his_winid, 'w')
            call win_execute(s:his_winid, 'setl nomodifiable')
        else
            let cbuf = bufnr("%")
            execute '1bufdo! setl write'
            silent execute '1bufdo! write'
            execute '1bufdo! setl nomodifiable'
        endif
        let s:interval = 500
    else
        let s:interval = min([s:interval * 2, s:threshold])
    endif

    if exists('cbuf') && cbuf != 1
        execute 'buffer! ' . cbuf
    endif
    call s:Timer()
endfunc

" Description:
"       View highlighted history.
"
" Steps:
"       1. Get id, by splitting current line with | as delimiter and return
"       index 0
"
"       2. Build request and response file,
"               g:history_dir/id/id.req
"               g:history_dir/id/id.res
"
"       3. Delete open req and res files, by calling delete#DeletebyExt() with
"       req and res as args.
"       4. Get scheme and host.
"       5. Split open request file and set buffer variables scheme and host.
"       6. Vertical split response file.
"       7. Move cursor back to history window

func s:View()
    try
        let id = getline('.') ->split(" | ")[0] ->trim()
        let his_file = g:history_dir .. id .. "/" .. id
        let req_file = his_file .. ".req"
        let res_file = his_file .. ".res"
        call delete#DeletebyExt("req")
        call delete#DeletebyExt("res")
        let [scheme, host] = Get_Host_Scheme()
        execute 'sp ' .. req_file
        let b:scheme = scheme
        let b:host = host
        call SetHostStatusLine()
        execute 'vsp ' .. res_file
        wincmd k
    catch /.*/
        let fail_msg = "View failed| " .. v:exception
        call logger#Log(fail_msg)
        echom fail_msg
    endtry
endfunc

func s:Conceal()
    syn clear ZXCHisHost
    syn match ZXCHisHost /[^|]*|\?/ display contained nextgroup=ZXCHisUriF

    " conceal upto value specified in g:conceal
    let cmd = "syn match ZXCHisUriF /.\\{" .. g:conceal .. "}/ display contained nextgroup=ZXCHisUriL"
    execute cmd

    let cmd = "syn match ZXCHisUriL /\\%>" .. g:conceal .. "v.*/ conceal"
    execute cmd
    hi link ZXCHisUriF ZXCHisUri
    hi link ZXCHisUriL ZXCHisUri
endfunc

fun Tapi_ReloadConfig(bufnum, arglist)
    call logger#Log("Reload")
    let tosend = "ReloadConfig"
    call ch_sendexpr(g:channel, tosend)
endfunc

func s:EditConfig()
    let vim_cmd = "vim --cmd \"let g:zxc_winame='popup'\" config.toml"
    let buf = term_start(vim_cmd, #{hidden: 1, term_finish: 'close'})
    let winid = popup_create(buf, g:popup_options)
endfunc

func s:SetupHistory()
    let g:history_dir = "./history/"
    let g:channel = socket#Connect("history")
    if exists("g:conceal")
        call s:Conceal()
    endif
    if exists('&winfixbuf')
        let s:his_winid = win_getid()
    endif
    call s:Timer()
endfunc

" -- settings
setl autoread
setl nowrap
if exists('&winfixbuf')
    setl winfixbuf
endif

" -- commands
command-buffer ConcealUri call s:Conceal()
command-buffer EditConfig call s:EditConfig()
command-buffer HistoryView call s:View()
command-buffer ReloadConfig call Tapi_ReloadConfig(1, [])

" -- Autocmd
augroup Enter
    autocmd VimEnter *.his call s:SetupHistory()
augroup End

augroup Flush
    autocmd WinEnter *.his call storage#Flush()
augroup End

augroup Close
    autocmd VimLeavePre  *.his set write | write
    autocmd BufDelete *.his call socket#Close()
augroup End

" -- Remaps
nnoremap <buffer><silent><CR> :HistoryView<CR>
