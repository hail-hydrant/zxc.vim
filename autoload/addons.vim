if exists('g:did_session')
    finish
endif
let g:did_session = 1
let g:channel = socket#Connect("addons")

" Steps:
"       1. Check if close message
"       2. Check if tabedit is required
"       3. edit request file
"       4. Open terminal
"       5. Send cmd to terminal
"       6. Clear terminal

func HandleMsg(msg)
    call tab#add()
    " Open destination request
    silent execute 'e' get(a:msg, 'file')
    " Split terminal and write cmd to terminal
    let cmd_id = term_start(&shell, {"term_finish": "close"})
    call term_sendkeys(cmd_id, get(a:msg, 'cmd'))
    call term_sendkeys(cmd_id, "\<c-l>")
endfunc
