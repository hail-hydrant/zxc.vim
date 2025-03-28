" Description:
"       Add update to send dictionary
" 
" Arg:
"       tosend : dict
"
" Steps:
"       if b:update exists and is v:false add it to tosend
"       By default binary sets update to true

func add_update#Add(tosend)
    if exists('b:update') && !b:update
        let a:tosend["update"] = v:false
    endif
endfunc
