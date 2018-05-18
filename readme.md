# vim-autosettags

When opening a file, autosettags plugins look for a file named .tags(g:ast_tagsfile) & make_tags(g:ast_mkfile) in the directory of the opened file and in every parent directory.

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
let g:ast_mkfile = 'make_tags.bat' "default windows
let g:ast_mkfile = 'make_tags.sh' "default linux
```

### Make .tags

```shell
\ctags -R --exclude=.git --exclude=node_modules --languages=PHP --langmap=PHP:.php --php-types=c+f+d -f .tags .
```
