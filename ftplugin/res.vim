if !check_session#Check() && exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

func s:OpenReq()
    let base = fnamemodify(path, ':r')
    let req = base .. ".req"
    leftabove vsplit req
endfunc

command-buffer OpenReq call s:OpenReq()
