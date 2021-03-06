# vim-autosettags

When opening a file, autosettags plugins look for a file named .tags(g:ast_tagsfile) & .tags(g:ast_mkfile) in the directory of the opened file and in every parent directory.

** search & set tags=/dir/.tags **
```
/dir/subdir/.tags
/dir/.tags
/.tags
```

## How to use

#### manual set tags

```
:call autosettags#ASTSetTags()
```

#### make tags file

```
:call autosettags#ASTMakeTags()
```

## Setting

### add (~/.vimrc)

#### example (command)

```vim
command! AST call autosettags#ASTSetTags()
command! ASTMakeTags call autosettags#ASTMakeTags()
```

#### example (default)

```vim
let g:ast_autoset = 1 "default
let g:ast_autoset_onetime = 1 "default
let g:ast_tagsfile = '.tags' "default
let g:ast_append = 1 "default [set tags+=]
let g:ast_setmsg = 1 "default show message(:set tags=xxxx)
let g:ast_mkfile = '.tags.bat' "default windows
let g:ast_mkfile = '.tags.sh' "default linux
```

### Make .tags

```shell
\ctags -R --exclude=.git --exclude=logs --languages=PHP --langmap=PHP:+.inc --php-kinds=-j -f .tags .
```
