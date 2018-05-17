# vim-autosettags

When opening a file, autosettags plugins look for a file named ".tags" in the directory of the opened file and in every parent directory.

```
/dev/dir1/dir2/.tags
/dev/dir1/.tags
/dev/.tags
/.tags
```

## How to use

```
command! AST call autosettags#ASTSetTags()
```

## Setting

### ~/.vimrc

```vim
let g:ast_tagsfile = '.tags' "default
let g:ast_autoset = 1 "default
```

### Make .tags

```shell
ctags -R --languages=PHP --langmap=PHP:.php --php-types=c+f+d -f .tags .
```
