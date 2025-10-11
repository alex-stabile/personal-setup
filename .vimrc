call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'sainnhe/everforest'
Plug 'alex-stabile/tokyonight-vim', {'branch': 'tweaks', 'as': 'tokyo-mod'}

call plug#end()

""
" Colors
"
set termguicolors
set background=dark
" Enable italics (required for Mac)
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
let g:everforest_better_performance = 1
let g:everforest_background = "hard"
let g:everforest_sign_column_background = "grey"
let g:everforest_disable_italic_comment = 1

colorscheme everforest

source ./.vim/setup.vim
