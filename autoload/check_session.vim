" Description:
"       Check if inside tmux and zxc.
"
" Steps:
"       1. Check if inside tmux
"       2. Check if inside zxc
"
" Returns:
"       bool

func check_session#Check()
    " 1. Check if inside tmux
    if empty($TMUX)
        return v:false
    endif

    " 2. Check if inside zxc
    call system("tmux showenv ZXC")
    if v:shell_error == 1
        return v:false
    endif

    return v:true
endfunc
