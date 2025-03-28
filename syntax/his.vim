if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim
setl nowrap

" Modded from
" https://www.reddit.com/r/vim/comments/wlelmg/csv_syntax_highlighting/

" Method
syn keyword ZXCHisHttpMethod  OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH contained

" Protocol
syn keyword ZXCHisProtocolHttps https contained
syn keyword ZXCHisProtocolHttp http contained

" Status Codes
syn match ZXCHisScodeSwitch '1[0-9]\{2\}' contained
syn match ZXCHisScodeSuccess '2[0-9]\{2\}' contained
syn match ZXCHisScodeRedirect '3[0-9]\{2\}' contained
syn match ZXCHisScodeClientError '4[0-9]\{2\}' contained
syn match ZXCHisScodeServerError '5[0-9]\{2\}' contained
syn match ZXCHisHttpContentLength '[0-9]\+' contained

" Index | Method | Status code | Content Length | Protocol | Host | Uri
syn match Index /[^|]*|\?/ display nextgroup=Method
syn match Method /[^|]*|\?/ display contains=ZXCHisHttpMethod contained nextgroup=Scode
syn match Scode /[^|]*|\?/ display contains=ZXCHisScodeSwitch,ZXCHisScodeSuccess,ZXCHisScodeRedirect,ZXCHisScodeClientError,ZXCHisScodeServerError contained nextgroup=CLength
syn match CLength /[^|]*|\?/ display contains=ZXCHisHttpContentLength contained nextgroup=Protocol
syn match Protocol /[^|]*|\?/ display contains=ZXCHisProtocolHttps,ZXCHisProtocolHttp contained nextgroup=ZXCHisHost
syn match ZXCHisHost /[^|]*|\?/ display contained nextgroup=ZXCHisUri
syn match ZXCHisUri /[^|]*|\?/ display contained

hi Index                                guifg=Yellow

" Method
hi link ZXCHisHttpMethod                Type

" Protocol
hi ZXCHisProtocolHttps                  ctermfg=Blue guifg=Blue
hi ZXCHisProtocolHttp                   ctermfg=Red  guifg=Red

" Status Code
hi ZXCHisScodeSwitch                    ctermfg=Blue guifg=Blue
hi ZXCHisScodeSuccess                   ctermfg=Green guifg=Green
hi ZXCHisScodeRedirect                  ctermfg=Yellow guifg=Yellow
hi ZXCHisScodeClientError               ctermfg=Red guifg=Red
hi ZXCHisScodeServerError               ctermfg=LightGrey guifg=LightGrey

" Content Length
hi link ZXCHisHttpContentLength         Number

" Host
hi link ZXCHisHost                      Statement

" Uri
hi link ZXCHisUri                       String

let b:current_syntax = "his"
let &cpo = s:cpo_save
unlet s:cpo_save
