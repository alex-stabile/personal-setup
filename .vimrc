call plug#begin('~/.vim/plugged')

Plug 'tmux-plugins/vim-tmux-focus-events'

Plug 'phanviet/vim-monokai-pro'
Plug 'ghifarit53/tokyonight-vim'

Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
" Plug 'HerringtonDarkholme/yats.vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
      \ 'coc-tsserver',
      \ 'coc-prettier',
      \ 'coc-eslint'
  \ ]

call plug#end()

" for dev server
set shell=/bin/bash
set termguicolors

" if you have that FZF issue...
" let $FZF_DEFAULT_COMMAND = ''
" unlet $FZF_DEFAULT_COMMAND

""
" CoC stuff
"
" bug: need to call s:reset() in coc/prompt.vim:s:start_prompt()
" let g:coc_disable_transparent_cursor = 0
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
" lists
nnoremap <silent> <space>e :<C-u>CocList diagnostics<cr>
" holy shit
" nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>

" Enable true color!
" Note: tmux can interfere if configured improperly. Make sure your .tmux.conf
" contains the following settings:
" set -g default-terminal "xterm-256color" # (or screen)

" # Tc allows vim to enable true colors, sitm allows vim to use italics
" set -as terminal-overrides ',xterm*:Tc:sitm=\E[3m'
" https://vimhelp.org/term.txt.html#xterm-true-color
" set termguicolors
" let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
" let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
"
" after all that...
set termguicolors
set background=dark

" required fzf setup
set rtp+=/usr/local/opt/fzf

""
" General settings
" Good resources:
" - http://stevelosh.com/blog/2010/09/coming-home-to-vim/#important-vimrc-lines
" - https://dougblack.io/words/a-good-vimrc.html
"
set noshowmode
set expandtab	" always insert spaces instead of tabs
set number	" turn on line numbers
set cursorline	" highlight current line (da best)
set wildmenu	" visual autocomplete for command menu
set showmatch	" highlight matching [{()}]
set visualbell  " use visual bell instead of beeping
set scrolloff=10 " number of lines to keep above and below the cursor
" Sensible line wrapping:
set breakindent
set breakindentopt=sbr " show showbreak char before applying indent
set showbreak=↪ " unicode curly
" set mouse=a
" Use cursorline in active window
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
" Allow having multiple files open and page through them with :bp and :bn.
" When switching files, preserve cursor location
" set hidden
set nostartofline
" Autocomplete : commands and show the last command
set wildmenu
set showcmd
" highlight search results and do case-insesitive searching except when
" including a capital
set hlsearch
set ignorecase
set smartcase
" Backspace will go to last indent instead of a single space
set backspace=indent,eol,start
" Show line number on left and current location in bottom right
" Alternatively, manually set status line to display above info, see :help
" statusline
" statusline=%<%f\ %h%r%=%-14.(%l,%c%V%)\ %P
" With a cool highlight color, git branch placeholder
" (but how to switch when not active?)
" statusline=%<%#PmenuSel#(Master)%f\ %h%r%=%-14.(%l,%c%V%)\ %P
" Useful statusline help:
" https://shapeshed.com/vim-statuslines/
set number
set ruler
" Always display last command and use a second line
set laststatus=2
set cmdheight=2
" require confirmation for various things
set confirm
" remove S from shortmess flags: this will display number of matches in
" message area when searching (e.g. "[1/3]")
set shortmess-=S

""
" Filetype/syntax configs
"
filetype plugin on
" JSON - use javascript parsing
autocmd BufNewFile,BufRead *.json set ft=javascript
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

" TEST
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
function! SynGroup()
  let l:s = synID(line('.'), col('.'), 1)
  echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun

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
" FZF: buffers
nnoremap <Leader>b :Buffers<CR>
" FZF: files (no CR to narrow down)
nnoremap <Leader>f :Files 
" reload current file because sometimes there are weird syntax issues?
nnoremap <Leader><Space> :edit %<CR>
" easier find word under cursor - use 'n' to mimic search next
nnoremap <leader>n *
" jump to match motion
nnoremap <leader>m %
" show full path of current file
nnoremap <leader>? :echo @%<cr>
" change word under cursor
nnoremap <leader>c ciw
" easier vsplit (and navigate to new split)
nnoremap <leader>v :vsplit<cr><c-w>l

""
" FZF Config
"
let previewopts = [
      \ '--layout=reverse',
      \ '--info=inline',
      \ '--bind',
      \ 'ctrl-d:preview-page-down,ctrl-e:preview-down,ctrl-u:preview-page-up,ctrl-y:preview-up',
      \ '--preview',
      \ 'cat {} || tree -d {} 2>/dev/null'
      \ ]
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': previewopts}, <bang>0)
" see: https://github.com/junegunn/fzf.vim/issues/732
let rgpreviewopts = [
      \ '--layout=reverse',
      \ '--info=inline',
      \ ]
command! -bang -nargs=* Rg
  \ call fzf#vim#grep('rg --column --no-heading --line-number --color=always '.shellescape(<q-args>),
  \ 0,
  \ fzf#vim#with_preview({'options': rgpreviewopts}),
  \ <bang>0)
" Alternate helper preview arguments:
" \ '~/.vim/plugged/fzf.vim/bin/preview.sh {}'

""
" Color stuff
"

" set monokai_pro colorscheme, with some modifications
function! TweakMonokai()
  set termguicolors
  colorscheme monokai_pro
  highlight Normal guibg=#1d1a1e
endfunction


""
" Experimental test stuff
" (not working)
"

function! SendTmuxCommand(pane, command)
  return "tmux send-keys -t " . a:pane . " '" . a:command . "' Enter"
endfunction

function! RunTest()
  " Are we in a test file?
  " Stolen from: https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
  let in_test_file = match(expand("%"), '\(_spec.rb\|_test.rb\|test_.*\.py\|_test.py\|.test.ts\|.test.ts\)$') != -1

  let pane = g:acs_test_pane
  let example = g:acs_test_example

  if in_test_file
    " Run tests matching what example is set to
    let test_command = "devbox rspec -- " . @% . " --example " . example
    " Overriding for now: run tests in the scope of the current line:
    let test_command = "devbox rspec -- " . @% . ":" . line('.')
    " in case the pane is in copy mode
    exec ":silent !tmux send-keys -t ".pane." -X cancel"
    exec ":silent !" . SendTmuxCommand(pane, test_command)
  else
    echo "Not in test file: " . @% . " (pane=".pane.", example=".example.")"
  end
endfunction

" Set the examples that tests will be run for
function! SetTestExample(example_name_str)
  let g:acs_test_example=a:example_name_str
endfunction

" Set the tmux pane that the test will run in
function! SetTestPane(pane_index)
  let g:acs_test_pane=a:pane_index
endfunction

" command! -nargs=1 SetTestExample call SetTestExample(<f-args>)
" command! -nargs=1 SetTestPane  call SetTestPane(<f-args>)
" command! RunTest call RunTest()

" TODO: fix this, it's conflicting with tabs
" nnoremap <Leader>t :RunTest<CR>

