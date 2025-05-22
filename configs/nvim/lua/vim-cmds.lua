vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "


--vim.cmd("set showmatch")     -- set show matching parenthesis
--vim.cmd("set ignorecase")    -- ignore case when searching
--vim.cmd("set smartcase")     -- ignore case if search pattern is all lowercase, case-sensitive otherwise
----vim.cmd("set visualbell")           -- don't beep
----vim.cmd("set noerrorbells")         -- don't beep
--vim.cmd("set title")                -- change the terminal's title
vim.cmd("set history=1000")         -- remember more commands and search history
vim.cmd("set undolevels=1000")      -- use many muchos levels of undo
--vim.cmd("set hlsearch")      -- highlight search terms
--vim.cmd("set incsearch")     -- show search matches as you type
vim.cmd("set number")        -- show line numbers
----set bg=light      -- set background/color scheme brightness. ex: light and dark
--vim.cmd("set scrolloff=10")   -- Makes scrolling down suck less
----set paste         -- Always have pasting on
----set pastetoggle=<F7> -- Toggle paste on/off with key
--vim.cmd("set backspace=2")   -- Make backspace work like most other apps
vim.cmd("tab all")           -- Show tabs for all files opened at once
--vim.cmd("set termguicolors")

-- Fix copy and paste
vim.cmd("set mouse=a")
vim.cmd("autocmd TextYankPost * if v:event['operator'] is 'y' && v:event['regname'] is '' | let @+ = @0 | endif")

