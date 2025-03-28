if !check_session#Check()
    finish
endif

let g:Scode = []

func SetScode(list)
    let g:Scode = a:list ->filter('strlen(v:val) == 3') ->sort() ->uniq()
endfunc

func s:AddScode(entry)
    if a:entry ->strlen() != 3
        echom "not valid scode| " .. a:entry
        return
    endif
    let g:Scode = g:Scode ->add(trim(a:entry)) ->sort() ->uniq()
endfunc

func s:ShowScode()
    let g:popup_options['title'] = " status codes "
    call popup_create(g:Scode, g:popup_options)
endfunc

command! -nargs=1 AddScode call s:AddScode(<f-args>)
command-buffer -bar ClearScode let g:Scode = []
command-buffer EditScode call create_popup#Create(g:Scode, "Scode")
command-buffer ShowScode call s:ShowScode()
