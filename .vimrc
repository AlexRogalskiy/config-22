" Pieced together from various sources, including:
" * vimcasts.org
" * https://github.com/carlhuda/janus
" * The O'Reilly book: http://oreilly.com/catalog/9780596529833
" * http://colemak.com/pub/vim/colemak.vim

set encoding=utf-8
set nocompatible                " make Vim behave in a more useful way
set lazyredraw                  " don't redraw screen while executing macros/mappings
set winaltkeys=no               " allow mapping of alt (meta) key shortcuts
set mouse=a                     " allow mouse in terminal version

" For colemak keyboard layout; source .vimrc-qwerty to undo
source ~/.vimrc-colemak

" Whitespace Settings
set autoindent                  " maintain indent level on new line
set expandtab                   " use soft tabs
set tabstop=4                   " use 4 spaces for tabs
set shiftwidth=4                " use 4 spaces for auto-indent
set softtabstop=4               " use 4 spaces for backspace

" Display of Non-Printing Characters
set list                        " show listchars
set listchars=tab:▸\ ,trail:-   " show tabs and trailing
set listchars+=eol:¬            " show end of line

" Horizontal Scrolling
set nowrap
set sidescroll=20               " show 20 more characters when scolling horizontally
set listchars+=extends:»,precedes:« " show horizontal continuation
set whichwrap=b,s,[,],<,>,h,l   " allow cursor to wrap between lines
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
"set wrapmargin=10              " for non-program text

" Cursor Management
set nostartofline               " keep cursor in the same column when moving lines if possible
set scrolloff=1                 " minimal number of screen lines to keep above and below the cursor

" Searching
set incsearch                   " enable incremental search
set nohlsearch                  " do not highlight search patterns
set ignorecase                  " ignore case
set smartcase                   " ignore case when the pattern contains lowercase letters only

" Visual
set virtualedit=block           " allow selecting a rectangle in visual mode

" Display
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set showtabline=2               " always show tab page labels
set number                      " display line numbers
set showmatch                   " match brackets

" Saving & Backup
"set hidden                      " you can change buffers without saving
set autowriteall                " auto-save when switching buffers or shelling command
set directory=~/.vim/backup
set backupdir=~/.vim/backup

" Folding
set foldenable                  " allow folding in syntax foldmethod
set foldcolumn=3                " show folding in margin

if has("autocmd")
    " Enable file type detection
    filetype on
    filetype plugin on

    " Enable intelligent indenting
    " may require set paste before pasting, and set nopaste after?
    filetype indent on
    filetype plugin indent on

    autocmd BufNewFile,BufRead *.as set filetype=actionscript
    autocmd BufNewFile,BufRead *.properties,*.targets,*.proj,*.build,*.csproj set filetype=xml

    " Syntax of these languages is fussy over tabs Vs spaces
    autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

    " Customizations based on house-style
    autocmd FileType html setlocal ts=2 sts=2 sw=2 noexpandtab
    autocmd FileType xml setlocal ts=2 sts=2 sw=2 noexpandtab
    autocmd FileType css setlocal ts=2 sts=2 sw=2 noexpandtab
    autocmd FileType javascript setlocal ts=4 sts=4 sw=4 expandtab

    " git syntax
    autocmd BufNewFile,BufRead *.git/COMMIT_EDITMSG     setf gitcommit
    autocmd BufNewFile,BufRead *.git/config,.gitconfig  setf gitconfig
    autocmd BufNewFile,BufRead git-rebase-todo          setf gitrebase
    autocmd BufNewFile,BufRead .msg.[0-9]*
        \ if getline(1) =~ '^From.*# This line is ignored.$' |
        \   setf gitsendemail |
        \ endif
    autocmd BufNewFile,BufRead *.git/**
        \ if getline(1) =~ '^\x\{40\}\>\|^ref: ' |
        \   setf git |
        \ endif

    " Auto strip whitespace on save for whitelisted file types
    autocmd BufWritePre *.c,*.css,*.html,*.xml,*.py,*.js :call <SID>StripTrailingWhitespaces()
    function! <SID>StripTrailingWhitespaces()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " Do the business:
        %s/\s\+$//e
        " Clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction

    " Restore cursor position
    autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

    " Auto detect filetype for extensionless files
    augroup newFileDetection
    autocmd CursorMovedI * call <SID>CheckFileType()
    augroup END
    function <SID>CheckFileType()
        if exists("b:countCheck") == 0
            let b:countCheck = 0
        endif

        let b:countCheck += 1

        " Don't start detecting until approx. 20 characters in buffer
        if &filetype == "" && b:countCheck > 20 && b:countCheck < 200
            filetype detect
        endif

        " If we've exceeded the count threshold, or a filetype has been detected,
        " delete the autocmd
        if b:countCheck >= 200 || &filetype != ""
            autocmd! newFileDetection
        endif
    endfunction
endif

" &t_Co = number of colors
if &t_Co > 2 || has("gui_running")
    colorscheme torte

    " Enable syntax highlighting
    syntax on

    " We need these commands to run after syntax highlighting
    highlight NonText guifg=#666666
    highlight SpecialKey guifg=#666666
endif

"if has("gui_running") | source $VIMRUNTIME/mswin.vim | endif

" Opens file relative to current file
let mapleader=','
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabedit %%

" Open help for word under cursor
map gh "zyw:exe "h ".@z.""<CR>

" Wrap -> enable sane soft-wrapping, which doesn't work in conjunction with set list
command! -nargs=* Wrap set wrap linebreak nolist

" Map autocompletion to Ctrl-Space to match IDEs
:imap <C-Space> <C-P>

" (GUI) Live line reordering (very useful)
nnoremap <silent> <C-S-Up> :move .-2<CR>|
nnoremap <silent> <C-S-Down> :move .+1<CR>|
vnoremap <silent> <C-S-Up> :move '<-2<CR>gv|
vnoremap <silent> <C-S-Down> :move '>+1<CR>gv|
inoremap <silent> <C-S-Up> <C-o>:move .-2<CR>|
inoremap <silent> <C-S-Down> <C-o>:move .+1<CR>|

