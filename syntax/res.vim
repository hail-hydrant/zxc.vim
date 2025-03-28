if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

" https://github.com/nicwest/vim-http

syn match ZXCResHttpVersion 'HTTP/[0-9.]\+' contained nextgroup=ZXCResHttpStatusCode

" Status codes
syn match ZXCResScodeSwitch '1[0-9]\{2\}' contained
syn match ZXCResScodeSuccess '2[0-9]\{2\}' contained
syn match ZXCResScodeRedirect '3[0-9]\{2\}' contained
syn match ZXCResScodeClientError '4[0-9]\{2\}' contained
syn match ZXCResScodeServerError '5[0-9]\{2\}' contained

syn match ZXCResHttpStatusCode '[0-9]\{3\}' contains=ZXCResScodeSwitch,ZXCResScodeSuccess,ZXCResScodeRedirect,ZXCResScodeClientError,ZXCResScodeServerError contained

syn match ZXCResponseLine '^HTTP/[0-9.]\+ [0-9]\{3\} .*$' contains=ZXCResHttpVersion,ZXCResHttpStatusCode contained

syn match ZXCResHeaderKey '^[A-Za-z0-9\-]*:' contained nextgroup=ZXCReqHeaderValue
syn match ZXCResHeaderValue ' \zs.*$' contained

syn match ZXCResHeaderLine '^[A-Za-z][A-Za-z0-9\-]*: .*$' contains=ZXCResHeaderKey,ZXCResHeaderValue contained

syn region ZXCResHeader start='^HTTP/[0-9.]\+ [0-9]\{3\}.*$' end='\n\s*\n' contains=ZXCResponseLine,ZXCResHeaderLine

hi ZXCResScodeSwitch            ctermfg=blue guifg=Blue
hi ZXCResScodeSuccess           ctermfg=Green guifg=Green
hi ZXCResScodeRedirect          ctermfg=Yellow guifg=Yellow 
hi ZXCResScodeClientError       ctermfg=Red guifg=Red
hi ZXCResScodeServerError       ctermfg=LightGrey guifg=LightGrey

hi link ZXCResHttpVersion       Statement
hi link ZXCResHeaderKey         Identifier
hi link ZXCResHeaderValue       String

let b:current_syntax = 'res'
let &cpo = s:cpo_save
unlet s:cpo_save
