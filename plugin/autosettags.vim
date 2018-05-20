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
if !exists('g:ast_append')
  let g:ast_append = 1
endif
if !exists('g:ast_mkfile')
  if has("win32") || has("win95") || has("win64") || has("win16")
    let g:ast_mkfile = '.tags.bat'
  else
    let g:ast_mkfile = '.tags.sh'
  endif
endif

if has("win32") || has("win95") || has("win64") || has("win16")
  let s:ds = '\'
else
  let s:ds = '/'
endif

let s:is_bufread = 0
let s:flg_settags = 0

augroup autosettags#AST
    autocmd!
    autocmd BufReadPost * call autosettags#ASTOnBufRead()
augroup END

command! AST call autosettags#ASTSetTagsPre()
command! ASTMakeTags call autosettags#ASTMakeTagsPre()

function! autosettags#ASTOnBufRead()
  if 1 == g:ast_autoset && 0 == s:flg_settags
    let s:is_bufread = 1
    call autosettags#ASTSetTags()
  endif
endfunction

function! s:get_filedir(dir, fname)

  let l:ast_tagsfile = fnamemodify(a:dir.s:ds.a:fname, ':p')

  if filereadable(l:ast_tagsfile)
    return a:dir.s:ds
  endif

  let l:dir = fnamemodify(a:dir.s:ds.'..'.s:ds, ':p:h')

  if 3 == strlen(l:dir)
    " echo 'windows root '
    return ''
  endif

  if '/' == l:dir
    " echo 'root directory / '
    return ''
  endif

  return s:get_filedir(l:dir, a:fname)

endfunction

function! autosettags#ASTSetTagsPre()
  let s:is_bufread = 0
  call autosettags#ASTSetTags()
endfunction

function! autosettags#ASTSetTags()

  let l:filedir = s:get_filedir(expand('%:p:h'), g:ast_tagsfile)
  if '' == l:filedir
    call s:confirm('note: not found ['.g:ast_tagsfile.']')
    let l:filedir = autosettags#ASTMakeTags()
    if '' == l:filedir
      return
    endif
  endif

  let l:tagsfile_path = fnamemodify(l:filedir.g:ast_tagsfile, ':p')

  if !filereadable(l:tagsfile_path)
    call s:confirm('error: could not read ['.l:tagsfile_path.']')
    return
  endif

  let l:cmd = 'set tags'
  if 1 == g:ast_append
    let l:cmd .= '+='
  else
    let l:cmd .= '='
  endif
  let l:cmd .= l:tagsfile_path
  execute  l:cmd
  let s:flg_settags = 1

  echo l:cmd

endfunction

function! autosettags#ASTMakeTagsPre()
  let s:is_bufread = 0
  call autosettags#ASTMakeTags()
endfunction

function! autosettags#ASTMakeTags()

  if 1 == s:is_bufread
    return ''
  endif

  let l:filedir = s:get_filedir(expand('%:p:h'), g:ast_mkfile)
  if '' == l:filedir
    call s:confirm('note: not found ['.g:ast_mkfile.']')
    return ''
  endif

  let l:ast_tagsfile = fnamemodify(l:filedir.g:ast_tagsfile, ':p')
  let l:mkfile_path = fnamemodify(l:filedir.g:ast_mkfile, ':p')

  if has("win32") || has("win95") || has("win64") || has("win16")
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
    call s:confirm('error: could not create ['.l:ast_tagsfile.']')
    return ''
  endif

  call s:confirm('info: created ['.l:ast_tagsfile.']')
  return l:filedir

endfunction

function s:confirm(msg)
  if 1 != s:is_bufread
    call confirm(a:msg)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
