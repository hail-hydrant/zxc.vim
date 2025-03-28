" Check if one tab is present or create new tab.
func tab#add()
    if tabpagenr('$') > 1 || (tabpagenr('$') == 1 && !empty(bufname('%')))
        silent execute 'tabe'
    endif
endfunc
