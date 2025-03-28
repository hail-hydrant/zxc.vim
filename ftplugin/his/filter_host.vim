if !check_session#Check()
    finish
endif

let g:HostScope = []

func SetHostScope(list)
    let g:HostScope = a:list ->sort() ->uniq()
endfunc

func s:AddToHostScope()
    let host = Get_Host_Scheme()[1]
    call insert(g:HostScope, host)
    " Remove duplicates
    let g:HostScope = g:HostScope ->sort() ->uniq()
    call logger#Log("Host added to scope| " .. host)
endfunc

func s:ShowHostScope()
    let g:popup_options['title'] = " Host "
    call popup_create(g:HostScope, g:popup_options)
endfunc

command-buffer AddToHostScope call s:AddToHostScope()
command-buffer -bar ClearHostScope let g:HostScope = []
command-buffer EditHostScope  call create_popup#Create(g:HostScope, "Host")
command-buffer ShowHostScope call s:ShowHostScope()
