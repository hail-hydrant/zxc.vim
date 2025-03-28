if !check_session#Check() && exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" Syntax:
"       id | -> | size
"
" Steps:
"       1. Find id of file, line_list[0]
"       2. Find extension of file, by splitting line and matching arrow,
"       line_list[1]
"               ->      wreq
"               <-      wres
"       3. Build file name, id.extension
"       4. Build file path, expand('%:h')/id.extension
"       5. Close previous wreq and wres buffers.
"       6. Open file in split
"       7. Jump to previous buffer

func s:ViewWsSessionHistory()
    try
        let line_list = getline('.') ->split(" | ")
    catch /.*/
        let fail_msg = "View| " .. v:exception
        call logger#Log(fail_msg)
        echom fail_msg
        return
    endtry

    let id = line_list[0]
    if line_list[1] == "->"
        let ext = "wreq"
    else
        let ext = "wres"
    endif

    let file_name = id .. "." .. ext
    let path = expand('%:h')
    let file_path = path .. "/" .. file_name

    " 5. close previous buffers
    if g:zxc_winame == "repeater"
        call delete#DeletebyExtWithException("wreq", "scratch.wreq")
    else
        call delete#DeletebyExt("wreq")
    endif
    call delete#DeletebyExt("wres")
    silent execute 'sp ' .. file_path
    wincmd p
endfunc

setl autoread

command-buffer ViewWsSessionHistory call s:ViewWsSessionHistory()
nnoremap <buffer><silent><CR> <scriptcmd>:ViewWsSessionHistory<CR>
