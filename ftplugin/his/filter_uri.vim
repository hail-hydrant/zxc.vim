if !check_session#Check()
    finish
endif

let g:UriScope = []

func SetUriScope(list)
    let g:UriScope = a:list ->sort() ->uniq()
endfunc

func s:AddToUriScope()
    let uri = getline('.') ->split(" | ")[-1] ->split(" |")[0] ->split("?")[0] ->trim()
    if empty(uri)
        return
    endif
    call insert(g:UriScope, uri)
    " Remove duplicates
    let g:UriScope = g:UriScope ->sort() ->uniq()
    call logger#Log("Uri added to scope| " .. uri)
endfunc

func s:ShowUriScope()
    let g:popup_options['title'] = " Uri "
    call popup_create(g:UriScope, g:popup_options)
endfunc

command-buffer AddToUriScope call s:AddToUriScope()
command-buffer ClearUriScope let g:UriScope = []
command-buffer EditUriScope  call create_popup#Create(g:UriScope, "Uri")
command-buffer ShowUriScope call s:ShowUriScope()
