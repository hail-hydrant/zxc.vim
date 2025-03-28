if !check_session#Check()
    finish
endif

let g:popup_options['filter'] = 'PopupKeyClose'

func PopupKeyClose(winid, key)
    if a:key == 'q'
        call popup_close(a:winid)
        return 1
    endif
    return 0
endfunc

func s:InList(tocheck, list)
    if empty(a:list) || empty(a:tocheck)
        return 1
    endif
    for entry in a:list
        if stridx(entry, "/r ") == 0
            let raw = entry ->split('/r ')[-1]
            if a:tocheck =~# raw
                call logger#Log("regex| " .. raw .. " | " .. a:tocheck)
                return 1
            endif
        else
            if a:tocheck == entry
                call logger#Log("straight| " .. entry .. " | " .. a:tocheck)
                return 1
            endif
        endif
    endfor
    return 0
endfunc

function! s:InScode(number)
    if empty(g:Scode)
        return 1
    endif
    for item in g:Scode
        if item =~ '^\d\{3}$'
            if a:number == item
                return 1
            endif
        else
            let regex = item ->substitute('x', '\\d', 'g')
            if a:number =~# regex
                return 1
            endif
        endif
    endfor
    return 0
endfunction

" Steps:
"       1. Open and clear all existing folds
"       2. Loop through each line in the buffer,
"       3. If current host is not in g:HostScope and current status code not
"       InScode and current uri is not in g:UriScope then assign end to current
"       line
"       4. Else fold the range
"       5. If the fold has not been closed after end of file, fold the range.

func s:ApplyFilters()
    silent! normal! zR
    silent! normal! zE

    let total_lines = line('$')
    let start = -1
    let end = -1

    for line_no in range(1, total_lines)
        let line_list = getline(line_no) ->split(" |") ->map('trim(v:val)')

        if !(s:InList(line_list[5], g:HostScope) && s:InScode(line_list[2])
                    \ && s:InList(line_list[-1], g:UriScope))
            if start == -1
                let start = line_no
            endif
            let end = line_no
        else
            if start != -1
                execute start . ',' . end . 'fold'
                let start = -1
                let end = -1
            endif
        endif
    endfor

    if start != -1
        execute start . ',' . end . 'fold'
    endif
endfunc

func s:ShowFilters()
    let todis = []
    if !empty(g:HostScope)
        let todis += [""]
        let todis += ["Host" , "-----"] + g:HostScope
        let todis += ["", ""]
    endif

    if !empty(g:Scode)
        let todis += ["Scode" , "-----"] + g:Scode
        let todis += ["", ""]
    endif

    if !empty(g:UriScope)
        let todis += ["Uri" , "-----"] + g:UriScope
    endif

    let g:popup_options['title'] = "  Filters  "
    call popup_create(todis, g:popup_options)
endfunc

command-buffer ApplyFilters call s:ApplyFilters()
command-buffer ClearFilters ClearHostScope | ClearScode | ClearUriScope
command-buffer ShowFilters call s:ShowFilters()

" ----- Options
setl foldminlines=0
setl foldmethod=manual
