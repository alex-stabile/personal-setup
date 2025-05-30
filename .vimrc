call plug#begin('~/.vim/plugged')

if has('nvim')
  Plug 'mason-org/mason.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'mhartington/formatter.nvim'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/nvim-cmp'
else
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'phanviet/vim-monokai-pro'
Plug 'alex-stabile/tokyonight-vim', {'branch': 'tweaks'}
Plug 'morhetz/gruvbox'

call plug#end()

" dual caps lock map keyboard mod:
" https://gist.github.com/tanyuan/55bca522bf50363ae4573d4bdcf06e2e?permalink_comment_id=4271644#macos

""
" CoC config
" Settings in: ~/.config/nvim/coc-settings.json
if !has('nvim')
  let g:coc_start_at_startup = 0
  let g:coc_global_extensions = [
      \ 'coc-tsserver',
      \ 'coc-prettier',
      \ 'coc-eslint',
      \ 'coc-json'
  \ ]
  let g:coc_disable_transparent_cursor = 1
  " also did:
  " set guicursor+=a:ver1-Cursor/lCursor
  " set guicursor+=n-v-c:block-Cursor
  if v:version < 802
    let g:coc_disable_startup_warning = 1
    let g:coc_start_at_startup = 0
  endif
  " show docs for thing under cursor
  nnoremap <silent> K :call CocAction('doHover')<CR>
  " gotos
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gr <Plug>(coc-references)
  " jump from next,prev errors
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)
  " symbol renaming
  nmap <leader>rn <Plug>(coc-rename)
  " lists
  nnoremap <silent> <space>e :<C-u>CocList diagnostics<cr>
  " o.O
  " nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>
endif

""
" Colors
"
" Make sure .tmux.conf includes:
" set -g default-terminal "xterm-256color"

set termguicolors
set background=dark
" Enable italics (required for Mac)
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

" See: https://github.com/morhetz/gruvbox/wiki/Configuration#ggruvbox_contrast_dark
let g:gruvbox_contrast_dark = "hard"
" colorscheme gruvbox
colorscheme slate

""
" General settings
" Good resources:
" - http://stevelosh.com/blog/2010/09/coming-home-to-vim/#important-vimrc-lines
" - https://dougblack.io/words/a-good-vimrc.html

set noshowmode
set expandtab	" always insert spaces instead of tabs
set number	" turn on line numbers
set cursorline	" highlight current line (da best)
set wildmenu	" visual autocomplete for command menu
set noshowmatch	" highlight matching [{()}]
set redrawtime=5000
set visualbell  " use visual bell instead of beeping
set scrolloff=10 " number of lines to keep above and below the cursor
" Sensible line wrapping:
set breakindent
set breakindentopt=sbr " show showbreak char before applying indent
set showbreak=↪ " unicode curly
set nostartofline
" Autocomplete : commands and show the last command
set wildmenu
set showcmd
" Searching
set hlsearch
set ignorecase
set smartcase
" Backspace will go to last indent instead of a single space
set backspace=indent,eol,start
set number
set ruler
" Always display last command and use a second line
" set laststatus=2
" set cmdheight=2
set confirm
" remove S from shortmess flags: this will display number of matches in
" message area when searching (e.g. "[1/3]")
set shortmess-=S
" Show cursorline in active window only
augroup CursorLine
    autocmd!
    autocmd WinEnter,FocusGained,BufEnter * set cursorline
    autocmd WinLeave,FocusLost * set nocursorline
augroup END
" Use relative line numbers in the active window
augroup RelativeNum
    autocmd!
    " qf = quickfix window
    let blacklist = ['fugitiveblame', 'nerdtree', 'qf']
    autocmd WinEnter,FocusGained,BufRead * if index(blacklist, &ft) < 0 | set number relativenumber | endif
    autocmd WinLeave,FocusLost * if index(blacklist, &ft) < 0 | set number norelativenumber | endif
augroup END

""
" Filetype/syntax config
"
filetype plugin on
autocmd BufNewFile,BufRead *.json set ft=jsonc
" use shell highlighting for files with no extension
autocmd BufNewFile,BufRead * if &ft == '' | set ft=sh | endif
autocmd BufNewFile,BufRead * if &syntax == '' | set syntax=sh | endif
" Fastlane is ruby so....
autocmd BufNewFile,BufRead * if expand('%') =~ 'Fastfile' | set syntax=ruby | endif
" Tabs
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
filetype indent plugin on
set autoindent
set shiftwidth=2
set tabstop=4
set softtabstop=2
set expandtab
syntax on

""
" Mappings
"

" Easier split movement
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Easier tab movement, mimic tmux
nnoremap <C-n> gt
nnoremap <C-p> gT
" Easier back
nnoremap <Backspace> b
" Reference current file's path in command mode
cnoremap <expr> %% expand('%:h').'/'
" yank copies to clipboard
vnoremap y y:call system('pbcopy', @")<CR>

""
" Leader Mappings
" Resource: https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
"

let mapleader = "\<Space>"
function! ToggleHighlight()
  if &hlsearch==1
    set nohlsearch
  else
    set hlsearch
  endif
endfunction
" clear highlights
nnoremap <Leader>h :nohlsearch<CR>
" nnoremap <silent> <Leader>h :call ToggleHighlight()<CR>
" save easily
nnoremap <Leader>w :w<CR>
" quit easily
nnoremap <Leader>q :q<CR>
" drop buffer easily
nnoremap <Leader>d :bdelete<CR>
nnoremap <Leader>e :Explore<CR>
" reload current file
nnoremap <Leader><Space> :edit %<CR>
" find word under cursor
nnoremap <leader>n *
" jump to match motion
nnoremap <leader>m %
" show full path of current file
nnoremap <leader>? :echo @%<cr>
" change word under cursor
nnoremap <leader>c ciw
" easier vsplit (and navigate to new split)
nnoremap <leader>v :vsplit<cr><c-w>l
" fix syntax issues
nnoremap <leader>s :syntax sync fromstart<CR>
" copy current filename to clipboard
nnoremap <leader>F
  \ :let @" = expand("%")<CR>
  \ y:call system('pbcopy', @")<CR>
" logs!!
nnoremap <Leader>m :messages<CR>
" FZF commands
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>f :Files<Space>
nnoremap <Leader>r :Rg<Space>

""
" Copy link to the current file + line on GitHub, e.g.:
" https://github.com/org/repo/blob/<sha>/file.go#L3
"
function! GetGitHubPermalink()
  let l:file = expand('%')
  let l:line = line('.')
  let l:repo_root = systemlist('git rev-parse --show-toplevel')[0]
  let l:rel_path = substitute(l:file, l:repo_root . '/', '', '')
  let l:commit = systemlist('git rev-parse HEAD')[0]
  let l:remote = systemlist('git config --get remote.origin.url')[0]

  " Convert SSH to HTTPS if needed
  if l:remote =~ '^git@'
    let l:remote = substitute(l:remote, 'git@', '', '')
    let l:remote = substitute(l:remote, ':', '/', '')
    let l:remote = 'https://' . l:remote
  endif
  let l:remote = substitute(l:remote, '.git$', '', '')

  let l:url = printf('%s/blob/%s/%s#L%d', l:remote, l:commit, l:rel_path, l:line)
  let @+ = l:url " Copy to system clipboard
  echo 'Copied permalink: ' . l:url
endfunction

command! -nargs=0 Permalink call GetGitHubPermalink()

""
" FZF Config
"

set rtp+=/usr/local/opt/fzf
" defaults
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let window = { 'width': 0.9, 'height': 0.8 }
let common_opts = [ '--layout=reverse', '--info=inline' ]
let preview_file = 'bat --color=always --theme=gruvbox-dark --style=numbers,header,grid {}'
let preview_line= 'bat --color=always --theme=gruvbox-dark --style=numbers,header,grid {1} --highlight-line {2}'

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(
    \ <q-args>,
    \ fzf#wrap({'window': window, 'options': common_opts + ['--preview', preview_file]}),
    \ <bang>0 )

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
    \ 'rg --column --no-heading --line-number '.shellescape(<q-args>),
    \ 0,
    \ {'window': window, 'options': common_opts + ['--preview', preview_line]},
    \ <bang>0 )
