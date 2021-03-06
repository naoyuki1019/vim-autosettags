scriptencoding utf-8
"/**
" * @file autosettags.vim
" * @author naoyuki onishi <naoyuki1019 at gmail.com>
" * @version 1.0.2
" */

if exists("g:loaded_autosettags")
  finish
endif
let g:loaded_autosettags = 1

let s:save_cpo = &cpo
set cpo&vim


if has("win32") || has("win95") || has("win64") || has("win16")
  let s:is_win = 1
  let s:ds = '\'
else
  let s:is_win = 0
  let s:ds = '/'
endif

let g:ast_autoset = get(g:, 'ast_autoset', 1)
let g:ast_autoset_onetime = get(g:, 'ast_autoset_onetime', 1)

if !exists('g:ast_tagsfile')
  let g:ast_tagsfile = '.tags'
endif
" [:set tags +=] or [:set tags =]
if !exists('g:ast_append')
  let g:ast_append = 1
endif
if !exists('g:ast_setmsg')
  let g:ast_setmsg = 1
endif
"mkfile ***.sh ***.bat
if !exists('g:ast_mkfile')
  if 1 == s:is_win
    let g:ast_mkfile = '.tags.bat'
  else
    let g:ast_mkfile = '.tags.sh'
  endif
endif

let g:ast_ask_one = get(g:, 'ast_ask_one', 1)
" Flag when asked if you want to Execute
let s:ast_ask_one_flg = 0

let s:find_mkfile = 0
let s:is_bufread = 0
let s:flg_settags = 0

" debug
let s:script_name = expand('<sfile>:t')
let s:debuglogfile = '~/.vim/debug-'.substitute(s:script_name, '\.vim', '', '').'.log'
if !exists('g:ast_debug')
  let s:debug = 0
else
  let s:debug = g:ast_debug
endif

augroup autosettags#AST
    autocmd!
    autocmd BufReadPost * call autosettags#ASTOnBufRead()
augroup END

command! AST call autosettags#ASTSetTags()
command! ASTMakeTags call autosettags#ASTMakeTags()

function! autosettags#ASTOnBufRead()
  if 1 == g:ast_autoset && (0 == g:ast_autoset_onetime || (1 == g:ast_autoset_onetime && 0 == s:flg_settags))
    if 0 == g:ast_ask_one || (1 == g:ast_ask_one && 0 == s:ast_ask_one_flg)
      let s:is_bufread = 1
      call autosettags#ASTSetTags()
      let s:is_bufread = 0
    endif
  endif
endfunction

function! s:search_tagsfile(dir)
  call s:debuglog('search_tagsfile dir', a:dir)

  let l:dir = a:dir

  if 1 == s:is_win
    if 3 == strlen(l:dir)
      let l:dir = l:dir[0:1]
    endif
  else
  endif

  let l:tagsfile_path = fnamemodify(l:dir.s:ds.g:ast_tagsfile, ':p')
  if filereadable(l:tagsfile_path)
    return l:dir.s:ds.g:ast_tagsfile
  endif

  let l:mkfile_path = fnamemodify(l:dir.s:ds.g:ast_mkfile, ':p')
  if filereadable(l:mkfile_path)
    let s:find_mkfile = 1
    let l:res = s:exec_make(l:dir.s:ds)
    if 0 == l:res
      return l:dir.s:ds.g:ast_tagsfile
    endif
  endif

  if 1 == s:is_win
    if 2 == strlen(l:dir)
      return ''
    endif
  else
    if '/' == l:dir
      return ''
    endif
  endif

  let l:dir = fnamemodify(l:dir.s:ds.'..'.s:ds, ':p:h')

  " Network file
  if l:dir == a:dir
    return ''
  endif

  " 念のため
  if 1 == s:is_win
    let l:match = matchstr(l:dir, '\V..\\..\\')
  else
    let l:match = matchstr(l:dir, '\V../../')
  endif
  if '' != l:match
    return ''
  endif

  return s:search_tagsfile(l:dir)

endfunction


function! s:search_mkfile(dir)
  let l:dir = a:dir

  if 1 == s:is_win
    if 3 == strlen(l:dir)
      let l:dir = l:dir[0:1]
    endif
  else
  endif

  let l:mkfile_path = fnamemodify(l:dir.s:ds.g:ast_mkfile, ':p')
  if filereadable(l:mkfile_path)
    let s:find_mkfile = 1
    let l:res = s:exec_make(l:dir.s:ds)
    if 0 == l:res
      return l:dir.s:ds.g:ast_mkfile
    endif
  endif

  if 1 == s:is_win
    if 2 == strlen(l:dir)
      return ''
    endif
  else
    if '/' == l:dir
      return ''
    endif
  endif

  let l:dir = fnamemodify(l:dir.s:ds.'..'.s:ds, ':p:h')

  " Network file
  if l:dir == a:dir
    return ''
  endif

  " 念のため
  if 1 == s:is_win
    let l:match = matchstr(l:dir, '\V..\\..\\')
  else
    let l:match = matchstr(l:dir, '\V../../')
  endif
  if '' != l:match
    return ''
  endif

  return s:search_mkfile(l:dir)

endfunction

function! autosettags#ASTSetTags()

  let l:dir = expand('%:p:h')

  if 1 == s:is_remote(l:dir)
    return
  endif

  let s:find_mkfile = 0
  let l:tagsfile_path = s:search_tagsfile(l:dir)
  if '' == l:tagsfile_path
    if 0 == s:find_mkfile
      call s:confirm('note: not found ['.g:ast_tagsfile.'] & ['.g:ast_mkfile.']')
    else
      call s:confirm('note: search end')
    endif
    return
  endif

  if !filereadable(l:tagsfile_path)
    call confirm('error: could not read ['.l:tagsfile_path.']')
    return
  endif

  let l:cmd = 'set tags'
  if 1 == g:ast_append
    let l:cmd .= '+='
  else
    let l:cmd .= '='
  endif
  let l:cmd .= l:tagsfile_path

  silent execute  l:cmd

  let s:flg_settags = 1

  if 1 == g:ast_setmsg
    echo l:cmd
  endif

endfunction

function! autosettags#ASTMakeTags()

  let l:dir = expand('%:p:h')

  if 1 == s:is_remote(l:dir)
    return
  endif

  let s:find_mkfile = 0
  let l:mkfile_path = s:search_mkfile(l:dir)
  if '' == l:mkfile_path
    if 0 == s:find_mkfile
      call confirm('note: not found ['.g:ast_mkfile.']')
    else
      call confirm('info: end')
    endif
    return
  endif

endfunction

function! s:exec_make(dir)

  let l:tagsfile_path = fnamemodify(a:dir.g:ast_tagsfile, ':p')
  let l:mkfile_path = fnamemodify(a:dir.g:ast_mkfile, ':p')

  if 1 == s:is_win
    let l:drive = a:dir[:stridx(a:dir, ':')]
    let l:execute = '!'.l:drive.' & cd '.shellescape(a:dir).' & '.shellescape(l:mkfile_path)
  else
    let l:execute = '!cd '.shellescape(a:dir).'; '.shellescape(l:mkfile_path)
  endif

  let l:conf = confirm('Execute? ['.l:execute.']', "Yyes\nNno")
  let s:ast_ask_one_flg = 1
  if 1 != l:conf
    return 2
  endif

  call delete(l:tagsfile_path)
  silent execute l:execute

  if !filereadable(l:tagsfile_path)
    call confirm('error: could not create ['.l:tagsfile_path.']')
    return 1
  endif

  call confirm('info: created ['.l:tagsfile_path.']')
  return 0

endfunction

"Do not display confirmation message when called by bufread
function! s:confirm(msg)
  if 1 != s:is_bufread
    call confirm(a:msg)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

function! s:is_remote(path)
  let l:pt = '\v(ftp:\/\/.*|rcp:\/\/.*|ssh:\/\/.*|scp:\/\/.*|http:\/\/.*|file:\/\/.*|https:\/\/.*|dav:\/\/.*|davs:\/\/.*|rsync:\/\/.*|sftp:\/\/.*)'
  let l:match = matchstr(a:path, l:pt)
  if '' != l:match
    call s:debuglog('is_remote l:match', l:match)
    return 1
  else
    call s:debuglog('is_not_remote a:path', a:path)
    return 0
  endif
endfunction

function! s:debuglog(title, msg)
  if 1 != s:debug
    return
  endif
  silent execute ":redir! >> " . s:debuglogfile
  silent! echon strftime("%Y-%m-%d %H:%M:%S")
        \.' | '.a:title.':'.a:msg."\n"
  redir END
endfunction

