if !check_session#Check()
    finish
endif

let s:modified = v:false

func s:SetMod()
    if &modified
        let s:modified = v:true
    endif
endfunc

" Send ReloadConfig command to history session if config.toml is modified.
func s:ReloadConfig()
    if bufname() == "config.toml" && (&modified || s:modified)
        exe "set t_ts=\<Esc>]51; t_fs=\x07"
        let &titlestring = '["call", "Tapi_ReloadConfig", []]'
        redraw
        set t_ts& t_fs&
    endif
endfunc

autocmd VimLeavePre *.toml call s:ReloadConfig()
autocmd BufWritePre *.toml call s:SetMod()
