" This must be first, because it changes other options as side effect
set nocompatible

filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
"Plugin 'rizzatti/dash.vim'

" Vundle Plugins
Plugin 'bling/vim-airline'

" End Vundle plugins

" All of your Plugins must be added before the following line
call vundle#end()            " required

filetype plugin indent on    " required

colorscheme sublimemonokai   " Set color scheme

set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase, case-sensitive otherwise
set visualbell           " don't beep
set noerrorbells         " don't beep
set title                " change the terminal's title
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type
set number        " show line numbers
set expandtab     " insert space characters when tab is pressed
set tabstop=4     " insert n spaces when tab is pressed
set shiftwidth=4  " insert n spaces when indenting
"set bg=light      " set background/color scheme brightness. ex: light and dark
set scrolloff=10   " Makes scrolling down suck less
"set paste         " Always have pasting on
"set pastetoggle=<F7> " Toggle paste on/off with key
set backspace=2   " Make backspace work like most other apps
tab all           " Show tabs for all files opened at once

" FROM DOSWALD'S PRESENTATION
set ruler
set showcmd
"set cursorline
set colorcolumn=120
"set wildmenu
"set wildmode=list:longest,full
set undodir=~/.vim/.undo//
set backupdir=~/.vim/.backup//
set directory=~/.vim/.swp//

syntax on

" make lines longer than 120 characters errors (including newline)
autocmd FileType perl match ErrorMsg /\%>119v.\+/

" Stop doing the annoying 'Ex mode' when hitting shift+Q
nmap Q <Nop>
map <D-PageUp> <Esc>:tabp<CR>
map <D-PageDown> <Esc>:tabn<CR>
nmap tq <Esc>:q<CR>
nmap tp <Esc>:tabp<CR>
nmap tn <Esc>:tabn<CR>
nmap tm <Esc>:tabm
nmap te <Esc>:tabe |
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>
nmap <C-Up> [e
nmap <C-Down> ]e

" Air-line settings
set laststatus=2
" To make the powerline fonts work with Airline
let g:airline_powerline_fonts = 1

" Auto indent when adding arrows in hashes in Perl
inoremap <silent> >        ><C-R>=SmartArrow()<CR>
function! SmartArrow ()
    if &filetype =~ '^perl' && search('^.*\S.*\s=>\%#$', 'bn', line('.'))
        return "\<ESC>"
            \. ":call EQAS_Align('nmap',{'pattern':'=>'})\<CR>"
            \. ":call EQAS_Align('nmap',{'pattern':'\\%(\\S\\s*\\)\\@<=#'})\<CR>"
            \. "A"
    else
        return ""
    endif
endfunction
