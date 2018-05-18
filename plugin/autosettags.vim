"/**
" * @file autosettags.vim
" * @author naoyuki onishi <naoyuki1019 at gmail.com>
" * @version 1.0
" */

if exists("g:loaded_autosettags")
  finish
endif
let g:loaded_autosettags = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:ast_autoset')
  let g:ast_autoset = 1
endif
if !exists('g:ast_tagsfile')
  let g:ast_tagsfile = '.tags'
endif
if !exists('g:ast_mkfile')
  if has('win32')
    let g:ast_mkfile = 'make_tags.bat'
  else
    let g:ast_mkfile = 'make_tags.sh'
  endif
endif


let s:flg_settags = 0
let s:dir = ''

augroup autosettags#AST
    autocmd!
    autocmd BufRead * call autosettags#ASTOnBufRead()
augroup END

command! AST call autosettags#ASTSetTags(0)
command! ASTMakeTags call autosettags#ASTMakeTags()

function! autosettags#ASTOnBufRead()
  if 1 == g:ast_autoset && 0 == s:flg_settags
    call autosettags#ASTSetTags(1)
  endif
endfunction

function! s:get_filedir(dir, fname)

  let l:ast_tagsfile = fnamemodify(a:dir.'/'.a:fname, ':p')

  if filereadable(l:ast_tagsfile)
    if has('win32')
      return a:dir.'\'
    else
      return a:dir.'/'
    endif
  endif

  let l:dir = fnamemodify(a:dir.'/../', ':p:h')

  if s:dir == l:dir
    " echo 'windows root ' . s:dir
    return ''
  endif

  if '/' == l:dir
    " echo 'root directory / '
    return ''
  endif

  let s:dir = l:dir

  return s:get_filedir(l:dir, a:fname)

endfunction

function! autosettags#ASTSetTags(is_onbufread)

  let l:filedir = s:get_filedir(fnamemodify('%', ':p:h'), g:ast_tagsfile)
  if '' == l:filedir
    let l:conf = confirm('note: not found ['.g:ast_tagsfile.']')
    let l:filedir = autosettags#ASTMakeTags()
    if '' == l:filedir
      return
    endif
  endif

  let l:tagsfile_path = fnamemodify(l:filedir.g:ast_tagsfile, ':p')

  if filereadable(l:tagsfile_path)
    execute 'set tags=' . l:tagsfile_path
    let s:flg_settags = 1
    if 1 != a:is_onbufread
      let l:conf = confirm('message: set tags=' . l:tagsfile_path)
    endif
  else
    if 1 != a:is_onbufread
      let l:conf = confirm('error: could not read ['.g:ast_tagsfile.']')
    endif
  endif

endfunction


function! autosettags#ASTMakeTags()

  let s:dir = ''
  let l:filedir = s:get_filedir(fnamemodify('%', ':p:h'), g:ast_mkfile)

  if '' == l:filedir
    let l:conf = confirm('note: not found ['.g:ast_mkfile.']')
    return ''
  endif

  let l:ast_tagsfile = fnamemodify(l:filedir.g:ast_tagsfile, ':p')
  let l:mkfile_path = fnamemodify(l:filedir.g:ast_mkfile, ':p')

  if has('win32')
    let l:drive = l:filedir[:stridx(l:filedir, ':')]
    let l:execute = '!'.l:drive.' & cd '.shellescape(l:filedir).' & '.shellescape(l:mkfile_path)
  else
    let l:execute = '!cd '.shellescape(l:filedir).'; '.shellescape(l:mkfile_path)
  endif

  let l:conf = confirm('execute? ['.l:execute.']', "Yyes\nNno")
  if 1 != l:conf
    return ''
  endif

  call delete(l:ast_tagsfile)
  silent execute l:execute

  if !filereadable(l:ast_tagsfile)
    let l:conf = confirm('error: could not create ['.l:ast_tagsfile.']')
    return ''
  endif

  let l:conf = confirm('info: created ['.l:ast_tagsfile.']')
  return l:filedir

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
