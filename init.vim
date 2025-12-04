set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

let g:loaded_python_provider = 0 " Turn off python2 checking. python3 still checked
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:airline_powerline_fonts = 1
"#######################################################################
" NERDTree
"#######################################################################
let g:NERDSpaceDelims = 1
let NERDTreeShowBookmarks = 1
"#######################################################################
" netrw
"#######################################################################
" let g:netrw_liststyle = 0     " Default view
" let g:netrw_liststyle = 1     " Show time and size
" let g:netrw_liststyle = 2     " Show in 2 columns
let g:netrw_liststyle = 3       " Show tree view
let g:netrw_browse_split=4      " ?
let g:netrw_altv=1              " Vertical split netrw v to the right
let g:netrw_preview=1           " Show preview in vertical
let g:netrw_winsize=50          " Set the windows size like hitting "v"
let g:netrw_fastbrowse=0        " ?
let g:netrw_silent=1            " transfers done silently
let g:netrw_keepdir= 0          " current dir tracks browse
autocmd FileType netrw setl bufhidden=delete
autocmd FileType yaml setlocal tabstop=2 expandtab shiftwidth=2 smarttab
" This opens netrw by default
" augroup ProjectDrawer
"     autocmd!
"     autocmd VimEnter * :Vexplore
" augroup END
"#######################################################################

"#######################################################################
" Spelling
"#######################################################################
" setlocal spell spelllang=en_us
" set spell spelllang=en_us
" [s, ]s, z=

"#######################################################################
" Diff
"#######################################################################
set diffopt+=vertical

" call plug#begin('C:\Users\wjs04\.vim\plugged')
call plug#begin()
    Plug 'preservim/nerdtree'
    Plug 'PProvost/vim-ps1'
    " Plug 'tpope/vim-surround' " which-key complains?
    Plug 'tpope/vim-fugitive'
    " Plug 'tpope/vim-repeat'
    Plug 'plasticboy/vim-markdown'
    Plug 'flazz/vim-colorschemes'
    " Plug 'preservim/nerdcommenter'
    " Plug 'godlygeek/tabular'
    " Plug 'easymotion/vim-easymotion'
   Plug 'elzr/vim-json'
    Plug 'nvim-lua/plenary.nvim'

if has("nvim")

    " Vim Script
    Plug 'burntsushi/ripgrep'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'folke/which-key.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects', {'do': ':TSUpdate'}
    Plug 'junegunn/fzf.vim'
    Plug 'kylechui/nvim-surround'
    " Plug 'nanotech/jellybeans.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'justinmk/vim-sneak'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'hashivim/vim-terraform'
endif

call plug#end()

" set clipboard=unnamedplus

" LEADER and ESCAPE and other WACKY mappings
imap jj <ESC>
nnoremap <space> <C-f>
nnoremap <tab> <C-w><C-w>
let mapleader=","
" v:count1 is probably 1.  Defaults to 1 when no count is given.
" :help v:count1
nnoremap <silent> <leader>o :<C-u>call append(line("."),   repeat([""], v:count1))<CR>
nnoremap <silent> <leader>O :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>

" odd-ball regex to somewhat catch an IP address
nnoremap <F5>  :%s/10\.1\.\(\d\{1,3}\)\.\(\d\{1,3}\)/10\.3\.\1\.\2/<CR>

" For which-key
set timeoutlen=500
" end which-key
set ignorecase
set smartcase
set copyindent
set smartindent
set autoindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set confirm

set number
" set splitright
set hidden
set mouse=a
set showtabline=0
set nofoldenable
"
" ctrl+w r for moving panes
"

if has("nvim")
    nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
    nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr
    nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
    :tnoremap <C-w> <C-\><C-n><C-w>
    :tnoremap <expr> <A-r> '<C-\><C-N>"'.nr2char(getchar()).'pi'
    augroup TerminalStuff
        au!
        autocmd TermOpen * setlocal nonumber norelativenumber
        autocmd TermOpen * startinsert
    augroup END
    colorscheme Atelier_ForestDark
    " This does live substitution
    set inccommand=split
"    
" The heredoc does not like indents
"
lua << EOF
require("which-key").setup {
-- your configuration comes here
-- or leave it empty to use the default settings
-- refer to the configuration section below
}
EOF
"    
" The heredoc does not like indents
"
lua <<EOF
require('telescope').setup {
    -- Default configuration for telescope goes here
    -- config_key = value,
    file_ignore_patterns = {".git/", ".cache", "%.o", "%.out", "%.class", "%.tmp"}
}
EOF

lua <<EOF
require('nvim-surround').setup {
    -- Configuration goes here or leave empty for defaults
}
EOF
endif

set listchars=eol:↲,tab:▶▹,nbsp:␣,extends:…,trail:•

" lua require'lspconfig'.bashls.setup{}

" Terraform LSP config "

" lua <<EOF
"   require'lspconfig'.terraformls.setup{}
" EOF
" autocmd BufWritePre *.tfvars lua vim.lsp.buf.formatting_sync()
" autocmd BufWritePre *.tf lua vim.lsp.buf.formatting_sync()
