" disable cc etc. using windows system clipboard
set clipboard=

" search settings
set ignorecase
set smartcase

" default mappings
map <Space> :
noremap 0 ^
noremap ^ 0
let g:mapleader = ","
nnoremap <leader>l :e!<CR>
nnoremap <leader>cs :noh<CR>

" disable visual/audio bells
set belloff=all

" disable esc-delay
set timeoutlen=200 ttimeoutlen=0

" lhs relnumbers with colors
set number relativenumber
highlight LineNr ctermfg=darkgrey ctermbg=black

if &diff
	colorscheme industry
endif

" plugged
if filereadable($HOME."/.vim/autoload/plug.vim")
	call plug#begin('~/.vim/plugged')

	map <C-t> :Tabularize /

	Plug 'PeterRincker/vim-argumentative'
	Plug 'editorconfig/editorconfig-vim'
	Plug 'godlygeek/tabular'
	Plug 'junegunn/vim-easy-align'
	Plug 'justinmk/vim-sneak'
	Plug 'tpope/vim-commentary'
	Plug 'tpope/vim-repeat'
	Plug 'tpope/vim-surround'
	Plug 'will133/vim-dirdiff'

	call plug#end()
endif
