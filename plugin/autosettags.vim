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


let s:is_bufread = 0
let s:flg_settags = 0
let s:dir = ''

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

  if filereadable(l:tagsfile_path)
    execute 'set tags=' . l:tagsfile_path
    let s:flg_settags = 1
    call s:confirm('message: set tags='.l:tagsfile_path)
  else
    call s:confirm('error: could not read ['.g:ast_tagsfile.']')
  endif

endfunction

function! autosettags#ASTMakeTagsPre()
  let s:is_bufread = 0
  call autosettags#ASTMakeTags()
endfunction

function! autosettags#ASTMakeTags()

  if 1 == s:is_bufread
    return ''
  endif

  let s:dir = ''
  let l:filedir = s:get_filedir(expand('%:p:h'), g:ast_mkfile)
  if '' == l:filedir
    call s:confirm('note: not found ['.g:ast_mkfile.']')
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
    call s:confirm('error: could not create ['.l:ast_tagsfile.']')
    return ''
  endif

  call s:confirm('info: created ['.l:ast_tagsfile.']')
  return l:filedir

endfunction

function s:confirm(msg)
  if 1 != s:is_bufread
    let conf = confirm(a:msg)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
