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

let s:flg_settags = 0
let s:dir = ''

augroup autosettags#AST
    autocmd!
    autocmd BufRead * call autosettags#ASTOnBufRead()
augroup END

command! AST call autosettags#ASTSetTags()

function! autosettags#ASTOnBufRead()
  if 1 == g:ast_autoset && 0 == s:flg_settags
    call autosettags#ASTSetTags()
  endif
endfunction

function! autosettags#ASTSetTags()
  call s:search_tagsfile(expand('%:h'))
endfunction

function! s:search_tagsfile(dir)
  let l:tagsfile_path = fnamemodify(a:dir.'/'.g:ast_tagsfile, ':p')
  " echo l:tagsfile_path
  if filereadable(l:tagsfile_path)
    execute 'set tags=' . l:tagsfile_path
    " echo 'set tags=' . l:tagsfile_path
    let s:flg_settags = 1
    return
  endif

  let l:dir = fnamemodify(a:dir.'/../', ':p:h')

  " win 'C: == C:' || linux '/ == /'
  if s:dir == l:dir || '/' == l:dir
    return
  endif

  let s:dir = l:dir

  return s:search_tagsfile(l:dir)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
