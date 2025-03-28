if !check_session#Check() || !exists("g:zxc_winame")
    finish
endif

" Install helptags
silent! helptags ALL

" Default settings for all windows
filetype plugin on
syntax on

set autoread
set laststatus=2
set nobackup
set noeol
set nofixendofline
set nowritebackup
set title
set updatetime=50

let g:session_name = split(getcwd(), "/")[-1]
let s:autoload_path = expand('<sfile>:p:h') .. "/../autoload/"

" Description:
"       Main function that loads other scripts and plugins based on the server.
"
" Steps:
"       1. Check if Debug Mode is on
"       2. Interceptor
"               - interceptor.vim
"               - codec.vim
"       3. Repeater
"               - repeater.vim
"               - codec.vim
"       4. Addons
"               - addons.vim

func s:StartModule()
    call s:CheckDebug()
    if g:zxc_winame =~ "interceptor"
        execute 'source ' .. s:autoload_path .. 'interceptor.vim'
        execute 'source ' .. s:autoload_path .. 'codec.vim'
        autocmd WinEnter * call storage#Flush()
    elseif g:zxc_winame =~ "repeater"
        execute 'source ' .. s:autoload_path .. 'repeater.vim'
        execute 'source ' .. s:autoload_path .. 'codec.vim'
        autocmd WinEnter * call storage#Flush()
    elseif g:zxc_winame =~ "addons"
        execute 'source ' .. s:autoload_path .. 'addons.vim'
    endif
endfunc

func s:CheckDebug()
    call system("tmux showenv ZXC_DEBUG")
    if v:shell_error == 0
        let g:DebugList = []
        let log_file = "./log/" .. g:zxc_winame .. "_chan.log"
        call ch_logfile(log_file, 'w')
    endif
endfunc

if !exists('g:popup_options')
    let g:popup_options = #{ minwidth: 50,
                \ minheight: 20,
                \ pos: 'center',
                \ border: [],
                \ borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'] }
endif

if !exists('g:timeout')
    let g:timeout = 5000
endif

call system("which getfattr")
let g:has_getfattr = !v:shell_error
 
" VimEnter event is used, since v:servername is set after VimEnter.
autocmd VimEnter * call s:StartModule()
autocmd VimLeavePre * call socket#Close()
autocmd CursorHold * try | checktime | catch | endtry

" https://www.reddit.com/r/vim/comments/oleraz/hide_terminal_buffer_from_buffer_list/
autocmd BufLeave * if &buftype=="terminal" | setlocal nobuflisted | set laststatus=2 | endif

command! -nargs=+ Greq cgetexpr grep#Grep("req", <f-args>)
command! -nargs=+ Gres cgetexpr grep#Grep("res", <f-args>)
command! -nargs=+ Greb cgetexpr grep#Grep("b", <f-args>)

command! -nargs=+ LGreq lgetexpr grep#Grep("req", <f-args>)
command! -nargs=+ LGres lgetexpr grep#Grep("res", <f-args>)
command! -nargs=+ LGreb lgetexpr grep#Grep("b", <f-args>)
