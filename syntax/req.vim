if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

" https://github.com/nicwest/vim-http

syn keyword ZXCReqMethod OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH contained

syn match ZXCReqURI ' \zs/[A-Za-z0-9._~!$&'()*+,;=:@%-]*\ze ' contained

syn match ZXCReqHttpVersion 'HTTP/[0-9.]\+' contained

syn match ZXCReqURILine '^\(OPTIONS\|GET\|HEAD\|POST\|PUT\|DELETE\|TRACE\|CONNECT\|PATCH\)\( .*\)\?\(HTTP/[0-9.]\+\)\?$'  contains=ZXCReqMethod,ZXCReqURI,ZXCReqHttpVersion contained

syn match ZXCReqHeaderKey '^[A-Za-z0-9\-]*:' contained nextgroup=ZXCReqHeaderValue
syn match ZXCReqHeaderValue ' \zs.*$' contained

syn match ZXCReqHeaderLine '^[A-Za-z][A-Za-z0-9\-]*: .*$' contains=ZXCReqHeaderKey,ZXCReqHeaderValue contained

syn region ZXCReqHeader start='^\(OPTIONS\|GET\|HEAD\|POST\|PUT\|DELETE\|TRACE\|CONNECT\|PATCH\)\( .*\)\?\(HTTP/[0-9.]\+\)\?$' end='\n\s*\n' contains=ZXCReqUriLine,ZXCReqHeaderLine

hi link ZXCReqMethod            Type
hi link ZXCReqURI               String
hi link ZXCReqHttpVersion       Statement
hi link ZXCReqHeaderKey         Identifier
hi link ZXCReqHeaderValue       String

let b:current_syntax = 'req'
let &cpo = s:cpo_save
unlet s:cpo_save
