# vim-autosettags

When opening a file, autosettags plugins look for a file named .tags(g:ast_tagsfile) & .tags(g:ast_mkfile) in the directory of the opened file and in every parent directory.

```
/dir/subdir/.tags
/dev/.tags
/.tags
```

## How to use

- manual set tags

	:AST

- make tags file

	:ASTMakeTags

## Setting

### ~/.vimrc

```vim
let g:ast_tagsfile = '.tags' "default
let g:ast_autoset = 1 "default
let g:ast_append = 1 "default [set tags+=]
let g:ast_mkfile = '.tags.bat' "default windows
let g:ast_mkfile = '.tags.sh' "default linux
```

### Make .tags

```shell
\ctags -R --exclude=.git --exclude=logs --languages=PHP --langmap=PHP:+.inc --php-kinds=-j -f .tags .
```
