# nvim help

## Buffers

- H: previous Buffer
- L: next buffer
- <leader>bd: delete buffer
- <leader>bb: switch to other buffer/last
- <leader>,: buffer picker


## Tag jumping

- ctrl-o
- ctrl-]
- `:ts`/`:tselect`: show tags
- `:tn`/ `:tp`

## spelling

- `setlocal spell spelllang=en_us`
- `]s`
- `[s`
- `]S` ?
- `]r` ?
- `z=` suggest for 'bad' words
- `spellr`: Do the last spell replace to all the others
- `zg` Add word local (good word to first name in `spellfile`)
- `spellr` 
- `zuw` undo `zw` and `zg`
- `zug` undo `zw` and `zg` in `spellfile`

## quickfix

### quickfix related commands

  - `help quickfix`
  - `vimgrep`
  - `grep`
  - `helpgrep`
  - `make`
  - spelling

### quickfix keys [c global, l local]

- `cc`, `cc<n>`: Display error
- `[count]cn`: Display next error
- `[count]cN`, `[count]cp`: Display previous error
- `copen`
- `cclose`
- `cdo`
- `:cdo s/foo/bar/ | update`
  - `cfdo bd` # to close buffers opened
- `cfirst`
- `clast`

- A 'location list' is a window-local quickfix list
  - `lvimgrep`
  - `lgrep`
  - `lhelpgrep`
  - `lmake`

## help

- `:h`
- `:help i_<help>`
- `:helpclose`

## helpgrep

Search all help text files and make a list of lines in which the pattern matches

- `:help helpgrep`
- quickfix

## quick

- `:help z`
- `z=` # spell check
- `:help g`
- `:help jumplist`
- `:help quickfix` list of positions in files
