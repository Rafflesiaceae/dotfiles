set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Mappings we can't use:
"   <C-m> → is Return in Terminals
"   <C-h> → jump to left window split
"   <C-l> → jump to right window split

let g:is_wsl = !empty($WSL_INTEROP) ? 1 : 0

if filereadable("/etc/vimrc")
    source /etc/vimrc
endif

set clipboard^=unnamed

set timeoutlen=250

if g:is_wsl
	set ttimeoutlen=5
    set fileformat=unix
else
	set ttimeoutlen=0
endif

let mapleader = ","
let g:mapleader = ","

set nocompatible
filetype off

" required for Ycm GoTo
set maxmempattern=8192

set matchpairs+=<:>

set autoindent

set bri
set foldlevel=99

set splitright

set foldmethod=marker

" keep indentations when you word-wrap
set breakindent

set number relativenumber
set showcmd showbreak=↪

" set tw=110 " 100 word wrap sounds good to me

map - @

" finally disable ex mode
nnoremap Q <Nop>

" need no help bindings
nmap <F1> <nop>
imap <F1> <nop>

" swap ^ and 0
noremap 0 ^
noremap ^ 0

" auto BufEnter * let &titlestring = hostname() . "/" . expand("%:p")
set title titlestring=%t titlelen=70

" set diffopt+=iwhite   " ignore changes in amount of white space
" set diffopt+=vertical " open diff-splits vertically

set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
set iskeyword=@,48-57,_,192-255

set scrollback=100000
set scrollopt+=hor

nnoremap <leader>sb :windo set scrollbind<cr>

highlight DiffChange cterm=none ctermfg=16 ctermbg=18 gui=none guifg=bg guibg=Red
autocmd FilterWritePre * if &diff | setlocal wrap< | endif


colorscheme base16-kokonai
let base16colorspace=256  " Access colors present in 256 colorspace
set background=dark

set t_kB=^[[Z " makes Shift+Tab work?!

let s:os = substitute(system('uname'), "\n", "", "")

" this should not do weird autothings with maxlinelen and instead only use it
" for `gq`
set formatoptions-=t
set textwidth=80

" https://vim.fandom.com/wiki/Fix_syntax_highlighting#Highlight_from_an_amount_backwards
" fromstart is impossible with larger files
autocmd BufEnter * :syntax sync minlines=1000 

" Configurations
" {{{ NeoVIM Nonsense
let g:editorconfig = v:false
" }}}
" {{{ YouCompleteMe
let g:ycm_confirm_extra_conf = 0 " don't ask for confirmation
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_autoclose_preview_window_after_insertion = 0
let g:ycm_key_list_select_completion   = ['<TAB>',   '<Down>', '<C-j>']
let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>',   '<C-k>']
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings  = 1
let g:ycm_auto_trigger = 1
let g:ycm_echo_current_diagnostic = 1
let g:ycm_global_ycm_extra_conf = $HOME.'/.config/ycm-extra-conf.py'

let g:ycm_filetype_blacklist = {
      \ 'tagbar' : 1,
      \ 'java' : 1,
      \ 'qf' : 1,
      \ 'notes' : 1,
      \ 'unite' : 1,
      \ 'infolog' : 1,
      \ 'mail' : 1,
      \ 'plain' : 1
      \}
let g:ycm_clangd_args = ['--clang-tidy']

let g:ycm_gopls_args = ['-remote=auto']
let g:ycm_gopls_binary_path = "~/.go/bin/gopls"

let g:ycm_semantic_triggers = {
    \ 'php' :  ['->', '::', '\']
    \ }

let g:ycm_gocode_binary_path = $HOME.'/.go/bin/gocode-gomod'
let g:ycm_godef_binary_path  = $HOME.'/.go/bin/godef-gomod'

let g:ycm_language_server = 
  \ [ 
  \   {
  \     'name': 'ansible',
  \     'cmdline': [ 'ansible-lsp' ],
  \     'filetypes': [ 'ansible' ],
  \   },
  \   {
  \     'name': 'nim',
  \     'cmdline': [ $HOME.'/.nimble/bin/nimlsp' ],
  \     'filetypes': [ 'nim' ],
  \   },
  \   {
  \     'name': 'terraform',
  \     'cmdline': [ $HOME.'/workspace/terraform-ls/terraform-ls', 'serve'],
  \     'filetypes': [ 'hcl' ],
  \   },
  \   {
  \     'name': 'json',
  \     'cmdline': [ $HOME.'/.node_modules/bin/vscode-json-languageserver', '--stdio' ],
  \     'filetypes': [ 'json' ],
  \     'capabilities': { 'textDocument': { 'completion': { 'completionItem': { 'snippetSupport': v:true } } } },
  \   },
  \ ]
  " \   {
  " \     'name': 'groovy',
  " \     'cmdline': [ 'java', '-jar', '/usr/share/java/groovy-language-server/groovy-language-server-all.jar' ],
  " \     'filetypes': [ 'groovy', 'gvy', 'gy', 'gsh' ],
  " \   }

nnoremap <leader>X :YcmRestartServer<CR>

" nnoremap <leader>g :YcmCompleter GoTo<CR>
" nnoremap <leader>pd :YcmCompleter GoToDefinition<CR>
" nnoremap <leader>pc :YcmCompleter GoToDeclaration<CR>

" }}}
" {{{ vim-go
" let g:go_def_mode='gopls'
let g:go_get_update = 0
let g:go_gopls_enabled = 0
" let g:go_gopls_options = ['-remote=auto']
" let g:go_info_mode='gopls'
" let g:go_referrers_mode = 'gopls'
" }}}
" " {{{ Syntastic
" let g:syntastic_python_checkers=[]
" let g:syntastic_php_checkers=['php']
" let g:syntastic_always_populate_loc_list=0
" let g:syntastic_check_on_open=0
" let g:syntastic_javascript_checkers = ['jshint']
" " let g:syntastic_javascript_checkers = ['']
" let g:syntastic_sh_checkers = ['shellcheck']
" " let g:syntastic_enable_perl_checker = 1
" let g:syntastic_enable_perl_checker = 0
" let g:syntastic_perl_checkers =  ['perl']
" let g:syntastic_lua_checkers =  ['luacheck']
" let g:syntastic_go_checkers = ['go', 'golint', 'govet']
" " let g:syntastic_perl_checkers =  ['']
" " let g:syntastic_warning_symbol = '⚠️'
" " let g:syntastic_python_flake8_args=''
" " }}}
" {{{ editorconfig
let g:EditorConfig_max_line_indicator = "none"
" }}}
" {{{ ALE
let g:ale_completion_enabled = 0
let g:ale_sign_error = '⤫'
let g:ale_sign_warning = '⚠'

let g:ale_linters_explicit = 1
let g:ale_linters = {
\   'bash': ['shellcheck'],
\   'c': [],
\   'cpp': [],
\   'javascript': [],
\   'java': [],
\   'markdown': [],
\   'objc': [],
\   'python': [],
\   'sh': ['shellcheck'],
\}

" }}}
" {{{ Airline
let g:airline_highlighting_cache = 1
"let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#ale#enabled = 0
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1 " disabled cause doesn't scroll like vim tab bar does
let g:airline#extensions#tabline#fnamecollapse = 0
let g:airline#extensions#whitespace#enabled = 0

let g:airline#extensions#tabline#fnamemod = ':p:~'
let g:airline#extensions#tabline#show_buffers = 0 " show only tabs like vim tabline
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_tabs = 0
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#tagbar#flags = 'f'
" let g:airline#extensions#tabline#fnametruncate = 10

" let g:airline#extensions#ycm#enabled = 1

" let g:airline#extensions#tagbar#enabled = 0

if !exists('g:airline_symbols')
   let g:airline_symbols = {}
endif

"" unicode symbols
let g:airline#extensions#tabline#left_sep = '▛'
let g:airline#extensions#tabline#right_sep = '▜'
let g:airline_left_sep = '»'
let g:airline_left_sep = '▙'
let g:airline_right_sep = '«'
let g:airline_right_sep = '▟'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '|'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_detect_paste=1
" let g:airline_theme="base16_kokonai.vim"

let g:airline_theme="base16_kokonai"

" }}}
" {{{ Ultisnips
let g:UltiSnipsExpandTrigger="<C-l>"
let g:UltiSnipsJumpForwardTrigger="<C-l>"
let g:UltiSnipsJumpBackwardTrigger="<C-o>"
let g:UltiSnipsUsePythonVersion = 2
" }}}
" {{{ Eclim
let g:EclimCompletionMethod = 'omnifunc'
" let g:EclimPhpIndentDisabled = 1
" }}}
" {{{ Ack / G
" chdir to git-project root before Acking
cnoreabbrev ag Gcd <bar> Ack!
if executable("ag")
    let g:ackprg = 'ag --vimgrep'
    let g:ackhighlight = 1

    " Grep
    set grepprg=ack\ -s\ -H\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c:%m,%f:%l:%m
    command! -bang -nargs=* -complete=file -bar G silent! grep! <args>
    autocmd QuickFixCmdPost *grep* cwindow
endif
let g:ack_use_dispatch = 1
" }}}
" {{{ Colorizer
let g:colorizer_auto_filetype='css,html,text'
" }}}
" {{{ Ctrlsf
let g:ctrlsf_mapping = {
    \ "next": "m",
    \ "prev": "M",
    \ "openb": "o",
    \ "loclist": "a",
    \ }
let g:ctrlsf_default_root = 'project'
let g:ctrlsf_auto_focus = {
    \ "at": "done",
    \ "duration_less_than": 4000
    \ }
let g:ctrlsf_ackprg = 'rg'
" }}}
" {{{ delimitMate
let g:delimitMate_expand_space = 1
let g:delimitMate_expand_cr = 1
let delimitMate_matchpairs = "(:),[:],{:}"
" }}}
" {{{ ctrlp
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']

if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:0'
" let g:ctrlp_match_window = 'max:10,results:0'
" }}}
" {{{ fzf
map <C-p> :FZF<CR>
" }}}
" {{{ Tagbar
map <Leader>a :Tagbar<CR>
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_map_help = "?"
" }}}
" {{{ Indent
" let g:PHP_autoformatcomment = 0
" let g:PHP_outdentphpescape = 0
" let g:PHP_BracesAtCodeLevel = 0
" let g:PHP_vintage_case_default_indent = 0
" }}}
" {{{ Indent-Guides
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 0

hi IndentGuidesOdd  guibg=red   ctermbg=234
hi IndentGuidesEven guibg=green ctermbg=19
" }}}
" {{{ vim-javascript
let g:javascript_plugin_jsdoc = 1
" }}}
" {{{ vim-json
let g:vim_json_syntax_conceal = 0
" }}}
" {{{ thrift
au BufRead,BufNewFile *.thrift set filetype=thrift
" au! Syntax thrift source ~/.vim/thrift.vim
" }}}
" {{{ AsyncRun
" Automatically open QF when running a cmd
augroup MyGroup
    autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
augroup END
:noremap <leader>qq :call asyncrun#quickfix_toggle(8)<cr>
" }}}
" {{{ Automatically close quickfix
aug QFClose
  au!
  au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix"|q|endif
aug END
" }}}
" {{{ Set default size for QF
" au FileType qf call AdjustWindowHeight(20, 10)
" function! AdjustWindowHeight(minheight, maxheight)
"   exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
" endfunction
" }}}
" {{{ miniyank
map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)
" }}}
" {{{ usher
au BufRead,BufNewFile *.ush set filetype=starlark
au BufRead,BufNewFile *.usher set filetype=starlark
" }}}
" {{{ neovim terminal
" G jumps to last outputted line instead of to the very bottom of the buffer, which in a terminal is always the complete height of the terminal emulator
au TermOpen * nno <buffer><nowait><silent> G :<c-u>call search('\S\_s*\%$')<cr>
" }}}
" {{{ easyalign
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}
" {{{ vim-fetch
nmap gf gF
" }}}
" {{{ fzf
" let g:fzf_preview_window = ['right:50%', 'ctrl-/']
" let g:fzf_layout = { 'down': '40%' }
" }}}
" {{{ godot
au BufRead,BufNewFile *.gd set filetype=gdscript
" au BufRead,BufNewFile *.usher set filetype=gdscript
au FileType gdscript set list
" }}}
" {{{ ansible-vim
let g:ansible_unindent_after_newline = 1
" }}}

" Rest
" {{{ Mappings
noremap <leader>d :Linediff<CR>

inoremap <M-o> <ESC>o

let mapleader = ","
let g:mapleader = ","

"h smartindent
inoremap # X#

" " " tab for brackets
" nnoremap <tab> %
" vnoremap <tab> %

nnoremap Y "+y

noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'

nnoremap <leader>e :e 
nnoremap <leader>E :OpenInVsCode<CR>

" <leader>v selects the just pasted text
nnoremap <leader>v V`]

" highlight on d-click
nnoremap <silent> <2-LeftMouse> :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>

" goto on t-click
nnoremap <silent> <3-LeftMouse> :YcmCompleter GoTo<cr>
nnoremap <silent> <leader>h :YcmCompleter GetDoc<cr>
nnoremap <silent> <leader>c :YcmCompleter GoToDeclaration<cr>

" ↓ https://vi.stackexchange.com/a/18489
nnoremap <silent> <expr> <C-n> g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"
nmap <S-Enter> O<Esc>

vnoremap // y/\V<C-R>"<CR>
nnoremap <leader>cs :noh<CR>

" nnoremap <leader>sp :cd %:p:h<CR>
" nnoremap <leader>ss :AsyncStop<CR>

nmap <leader>pw :cd %:p:h<CR>

nnoremap <leader>m :buffers<CR>:buffer<Space>
nnoremap <leader>M :sp<CR><C-W><C-J>:e ~/marks<CR>gg
nnoremap <leader>B :sp<CR><C-W><C-J>:e ~/breakpoints<CR>G

" nnoremap <silent> <C-M-p> :call fzf#vim#files(system('workspace-root \| tr -d "\n"'), 0)<CR>
" nnoremap <silent> <M-p>   :call fzf#vim#files(system('workspace-root \| tr -d "\n"'), 0)<CR>

nnoremap <C-s> :w!<CR>
inoremap <C-s> <C-O>:w!<CR>
nnoremap <leader>w :w!<CR>
nnoremap <leader>W :w!<CR>:e!<CR>
nnoremap <leader>l :e!<CR>

inoremap <C-e> <C-o>de

map <C-g> :CtrlSF 
nmap <C-f> :CtrlSF<CR>
vmap <C-f> <Plug>CtrlSFVwordExec<CR>
nmap <leader>f :CtrlSFToggle<CR>
vmap <leader>f <Plug>CtrlSFVwordExec
map <leader>F :CtrlSFUpdate<CR>

map <C-t> :Tabularize /
nnoremap <silent> <C-y> :YcmCompleter GetType<CR>
nmap <silent> <S-k> :YcmCompleter GetHover<CR>

" @TODO only in diffmode ( https://vi.stackexchange.com/a/2706 ?)
" nnoremap <silent> <leader>dp V:diffput<cr>
" nnoremap <silent> <leader>dg V:diffget<cr>

nnoremap <silent> <leader>vb :Gblame<cr>

" nnoremap <silent> <leader>s :%s/\<<C-r><C-w>\>/
" @TODO dont use yank buff, but visual selection instead
" nnoremap <leader>s :%s/\<<C-R>"\>/
nnoremap <leader>s :%s///g<Left><Left>

nnoremap <silent> <leader>cf :cd %:p:h<CR>

nnoremap - @

nnoremap <leader>r :Run<CR>
nmap <leader>o :let @*=expand("%:p")<CR>
map <C-q> :qa!<CR>
" map <C-c> :w<CR>

" handle escape in terminal mode differently
au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
au FileType fzf tunmap <buffer> <Esc>

cnoremap <C-a> <Home>

vnoremap Y "+y<CR>
vnoremap <C-c> "+y<CR>
nnoremap <leader>cy :%y+<CR>
vnoremap <leader>cy "+y<CR>
nnoremap <leader>cd :%d+<CR>
vnoremap <leader>cd "+d<CR>
nnoremap <leader>cp "+p<CR>
nnoremap <F3> "+P<CR>
inoremap <F3> <C-r>+
nnoremap <leader>cP "+P<CR>
nnoremap <leader>cw "+yiw<CR>

nnoremap <leader>m :buffers<CR>:buffer<Space>

noremap <leader>gt :OpenTig<CR>
noremap <leader>! :OpenTig<CR>
noremap <leader>" :OpenTig expand("%:p")<CR>
noremap <leader>C :OpenTerminal<CR>
noremap <leader>T :OpenTerminal<CR>
noremap <leader>P G:call search('^\([ -1234567890]\)\{3}raf', 'W')<CR>
noremap <leader>gc :Git commit<CR>
noremap <leader>gd :Gdiff<CR>
noremap <leader>gb :Git blame<CR>
noremap <leader>gs :GitGutterStageHunk<CR>
noremap <leader>gn :GitGutterNextHunk<CR>
noremap <leader>gp :GitGutterPrevHunk<CR>
noremap <leader>G  :GitGutterPreviewHunk<CR>
noremap <leader>gu :GitGutterUndoHunk<CR>
xnoremap <leader>s y/\V\<<C-r>"\><CR>

" Google it - TODO for visual selection
nnoremap <leader>gg :call system("chromium \"http://www.google.com/search?q=".expand("<cword>")."\"")<CR>

" nnoremap <silent> # :execute "normal! #n"<cr>
" nnoremap <silent> # /<C-r><C-w>/<cr>N
" nnoremap <silent> # :echo expand("<cword>")<cr>
nnoremap <silent> # :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>

" reselect pasted text http://vim.wikia.com/wiki/Selecting_your_pasted_text
nnoremap gp `[v`] 

" YCM
" nnoremap <CR> :YcmCompleter GoTo<CR>
" nnoremap <BS> :YcmCompleter 
" nnoremap <buffer> <CR> :YcmCompleter GoTo<CR>
" nnoremap <silent> <BS> :YcmCompleter GoToReferences<cr>
set wildcharm=<tab>
nnoremap <leader>2 :YcmCompleter RefactorRename <C-r><C-w>
nnoremap <BS> :YcmCompleter <tab>
nnoremap <CR> :YcmCompleter GoTo<CR>
nnoremap <leader>R :YcmCompleter RefactorRename <C-r><C-w>
nnoremap <leader>t :YcmCompleter GoToType<CR>
nnoremap <silent> <c :pclose<CR>
nnoremap <silent> <h :YcmCompleter GetDoc<CR>
nnoremap <silent> <n :cn<CR>
nnoremap <silent> <p :cp<CR>
nnoremap <silent> <P :cfirst<CR>
nnoremap <silent> <N :clast<CR>
nnoremap <silent> <w :cw<CR>

" " move-lines XXX: I never used this
" nnoremap <A-j> :m .+1<CR>==
" nnoremap <A-k> :m .-2<CR>==
" inoremap <A-j> <Esc>:m .+1<CR>==gi
" inoremap <A-k> <Esc>:m .-2<CR>==gi
" vnoremap <A-j> :m '>+1<CR>gv=gv
" vnoremap <A-k> :m '<-2<CR>gv=gv

" append to l-register TODO
" vnoremap <leader>cl "Ayy

" rmb
set mousemodel=popup
nnoremap <silent> <RightMouse> :call ClipboardPasteAsNewline()<CR>
inoremap <silent> <RightMouse> <C-o>:call ClipboardPasteInline()<CR>

vnoremap <silent> <RightMouse> "+y

" grammar
let g:grammarous#jar_url = 'https://www.languagetool.org/download/LanguageTool-5.9.zip'
nmap <leader>gr <Plug>(grammarous-open-info-window)
nmap <leader>grn <Plug>(grammarous-move-to-next-error)
nmap <leader>grp <Plug>(grammarous-move-to-previous-error)
" }}} Mappings

" {{{ Autocommands

" automatically hightlight the agt-query when reading agt results
autocmd BufRead /tmp/agt let @/ = readfile("/tmp/agt-query")[0] | call feedkeys("/\<CR>")

autocmd BufRead,BufNewFile tsconfig.json set filetype=json5

" BASH
autocmd BufNewFile   *.sh 0r ~/.vim/templates/sh
autocmd BufWritePre  *.sh call s:AddExecutablebitPre()
autocmd BufWritePost *.sh call s:AddExecutablebitPost()

autocmd FileType sh setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

" detect filetype sh
function! DetectShFiletype()
    let first_line=getline(1)
    if first_line =~# '^#!.*\<bash\>'
        set filetype=bash
    elseif first_line =~# '^#!.*\<sh\>' || first_line =~# '^#!.*\<dash\>' || first_line =~# '^#!.*\<zsh\>'
        set filetype=sh
    endif
endfunction
autocmd BufRead,BufNewFile,BufWrite * call DetectShFiletype()

" detect filetype ansible
function! DetectAnsibleFiletype()
    let last_line=getline('$')
    if last_line == '# code: language=ansible'
        set filetype=yaml.ansible
    endif
endfunction
au BufRead,BufNewFile,BufWrite *.yml call DetectAnsibleFiletype()
" au BufRead,BufNewFile *.ansible.yml set filetype=ansible
" au FileType ansible setlocal commentstring=#\ %s

au BufRead,BufNewFile project.config set filetype=dosini

" systemd
autocmd BufRead,BufNewFile *.service,*.timer set filetype=systemd

" JSON
autocmd FileType json setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType json setlocal foldmethod=syntax

" XML
autocmd FileType xml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

" Jenkinsfile
autocmd FileType groovy setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType Jenkinsfile setlocal commentstring=//\ %s
" autocmd BufRead,BufNewFile Jenkinsfile set filetype=groovy

" JS
autocmd FileType javascript setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType javascript setlocal commentstring=//\ %s
" autocmd FileType javascript noremap <buffer> <leader>r :call JsBeautify()<cr>
" autocmd FileType javascript noremap <buffer> <leader>r :!node %<cr>
" autocmd FileType javascript noremap <buffer> <cr> :YcmCompleter GetDoc<cr>
autocmd FileType javascript noremap <buffer> <cr> :YcmCompleter GoTo<cr>
autocmd FileType javascript nnoremap <silent> <leader>pp :silent execute ":!/Applications/PhpStorm.app/Contents/MacOS/phpstorm --line ".line('.')." ".expand("%:p")<cr>

autocmd BufWritePre  *.js call s:AddExecutablebitPre()
autocmd BufWritePost *.js call s:AddExecutablebitPost()

" TYPESCRIPT
autocmd FileType typescript noremap <silent> <buffer> <cr> :YcmCompleter GoToDefinition<cr>
autocmd FileType typescript noremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>
autocmd FileType typescript noremap <buffer> <leader>nr :YcmCompleter RefactorRename 
autocmd FileType typescript noremap <buffer> <leader>d :YcmCompleter FixIt<cr>

autocmd BufWritePre  *.ts call s:AddExecutablebitPre()
autocmd BufWritePost *.ts call s:AddExecutablebitPost()

" Python
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4
\ formatoptions=croqj softtabstop=4 textwidth=74 comments=:#\:,:#
" TODO use to surround visual-selection with some sort of debug-printing
autocmd FileType python let num_dd_print_re=""
autocmd FileType python noremap <silent> <buffer> <cr> :YcmCompleter GoTo<cr>
autocmd FileType python noremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>
autocmd FileType python nnoremap <silent> <leader>pp :execute ":!pycharm --line ".line('.')." ".expand("%:p")<cr>
" autocmd FileType python nnoremap <leader>r :w!<CR> :!python %<CR>
"
autocmd BufWritePre  *.py call s:AddExecutablebitPre()
autocmd BufWritePost *.py call s:AddExecutablebitPost()

" HTML
" autocmd FileType html nnoremap <leader>r :w!<CR> :!chromium %<CR>

" PHP
autocmd FileType php nnoremap <silent> <buffer> <cr> :PhpSearchContext -s project<cr>
" actually make it silent
autocmd FileType php nnoremap <silent> <leader>pp :execute ":!phpstorm --line ".line('.')." ".expand("%:p")<cr>
autocmd FileType php set tw=80 " for multi-line comments

" NIM
" autocmd FileType nim nnoremap <leader>r :w!<CR> :!nim c -r %<CR>

" CPP
let c_no_curly_error=1
autocmd FileType c   setlocal expandtab shiftwidth=3 tabstop=3 softtabstop=3
autocmd FileType cpp setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
" autocmd FileType c,cpp nnoremap <silent> <buffer> <C-c> :YcmCompleter GoTo<CR> 
" autocmd FileType c,cpp nnoremap <silent> <buffer> <C-a> :ExpandAuto<CR> 
autocmd FileType c,cpp nnoremap <silent> <buffer> <CR> :YcmCompleter GoTo<CR> 
autocmd FileType c,cpp nnoremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>
autocmd FileType c,cpp nnoremap <silent> <buffer> <C-m> :YcmCompleter GoToImplementation<cr>
autocmd BufRead,BufNewFile *.CPP set filetype=cpp
autocmd BufRead,BufNewFile *.map set filetype=raw
autocmd BufRead,BufNewFile *.map :GitGutterDisable

autocmd FileType c,cpp nnoremap <silent> <buffer> <F1> :call CurtineIncSw()<CR>
" autocmd FileType cpp nnoremap <leader>r :w!<CR> :!runcpp %<CR>
"
autocmd FileType c,cpp setlocal commentstring=//\ %s


" autocmd FileType c   noremap <silent> <buffer> <leader>x "=strftime('%c')<CR>
" autocmd FileType c   noremap <silent> <buffer> <leader>x O<ESC>""=strftime('%c')<C-M>P

" RUST
autocmd FileType rust nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR> 
autocmd FileType rust nnoremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>

" OBJC
autocmd FileType objc setlocal commentstring=//\ %s

" GO
" autocmd FileType go nnoremap <leader>r :w!<CR> :!go run %<CR>
autocmd FileType go nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR>
autocmd FileType go nnoremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>
autocmd FileType go nnoremap <silent> <buffer> <leader>gi :GoImports<CR>
autocmd FileType go nnoremap <silent> <buffer> <leader>gt :GoTest<CR>
" autocmd FileType go nnoremap <silent> <buffer> <leader>r :GoImports <CR> \| :belowright 20split \| terminal go run %<CR>
" autocmd FileType go nnoremap <silent> <buffer> <leader>r :GoImports<CR>:Run<CR>
" https://github.com/fatih/vim-go/issues/502#issuecomment-169083550
autocmd BufWritePost *.go normal! zv
autocmd FileType go let b:delimitMate_matchpairs = "(:),[:],{:}"
autocmd FileType go nnoremap <F2> :YcmCompleter RefactorRename <C-r><C-w>

" NIM
autocmd FileType nim nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR> 
autocmd FileType nim nnoremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>

" ELIXIR
" autocmd FileType elixir nnoremap <leader>r :w!<CR> :!elixir %<CR>

" PERL
" autocmd FileType perl nnoremap <leader>r :w!<CR> :!perl %<CR>

" PG/SQL
autocmd FileType sql nnoremap <silent> <buffer> <leader>c :!pgsanity %:p<CR>

" Git commits
autocmd FileType gitcommit set tw=72

" JSON
autocmd BufRead,BufNewFile tsconfig.json set filetype=json5

" JSON5
autocmd FileType json5 setlocal commentstring=//\ %s

" YAML
autocmd FileType yaml,yaml.ansible setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml,yaml.ansible setlocal indentkeys-=0# " stop comments from increasing indent
autocmd FileType yaml,yaml.ansible filetype indent off
autocmd FileType yaml,yaml.ansible set equalprg=cat

" MARKDOWN
autocmd FileType markdown setlocal list
autocmd FileType markdown nnoremap <silent> <buffer> <leader>r :LivedownPreview<CR>

" reSructured text
autocmd FileType rst nnoremap <silent> <buffer> <leader>r :silent !rstpreview % <CR>

" CMAKE
autocmd FileType cmake setlocal commentstring=#\ %s

" InnoSetup
autocmd FileType iss set filetype=pascal
autocmd FileType pascal setlocal commentstring=//\ %s

" GROOVY
au BufRead,BufNewFile *.gvy set filetype=groovy
autocmd FileType groovy nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR>

" nosh
au BufRead,BufNewFile *.nosh set filetype=starlark
au BufWritePre        *.nosh call s:AddExecutablebitPre()
au BufWritePost       *.nosh call s:AddExecutablebitPost()

" HCL
autocmd FileType hcl setlocal expandtab shiftwidth=2 tabstop=2

" Terraform
au BufRead,BufNewFile *.tfstate* set filetype=json

" scons
au BufRead,BufNewFile SConscript,SConstruct set filetype=python

" Makefile
autocmd BufRead,BufNewFile *.make set filetype=make

" pixi
autocmd BufRead,BufNewFile pixi.lock set filetype=yaml

" gdshader
autocmd FileType gdshader setlocal commentstring=//\ %s

autocmd BufRead,BufNewFile *.lds set filetype=ld

" <leader>j autoformatting/testing
augroup _leader_j
autocmd FileType bash noremap <leader>j :silent !autoformat-sh %<CR>
autocmd FileType c   noremap <leader>j :silent !autoformat-c %<CR>
autocmd FileType cpp noremap <leader>j :silent !autoformat-cpp %<CR>
autocmd FileType css noremap <leader>j :silent !autoformat-css %<CR>
autocmd FileType go noremap <leader>j :silent !autoformat-go %<CR>
autocmd FileType hcl noremap <leader>j :silent !autoformat-hcl %<CR>
autocmd FileType html   noremap <leader>j :silent !autoformat-html %<CR>
autocmd FileType javascript noremap <leader>j :silent !autoformat-js %<CR>
autocmd FileType json noremap <leader>j :silent !autoformat-json %<CR>
autocmd FileType lua noremap <leader>j :!autoformat-lua %<CR>
autocmd FileType nix noremap <leader>j :silent !nixpkgs-fmt %<CR>
autocmd FileType python noremap <leader>j :silent !autoformat-python %<CR>
autocmd FileType typescript,typescriptreact noremap <leader>j :silent !autoformat-ts %<CR>
autocmd FileType xml noremap <leader>j :silent !autoformat-xml %<CR>
autocmd FileType yaml noremap <leader>k :!actionlint %<CR>
autocmd FileType yaml,yaml.ansible noremap <leader>j :silent !yamlfmt %<CR>
" autocmd FileType javascript noremap <leader>j :silent !prettier -w %<CR>
" autocmd FileType nix noremap <leader>j :silent !nixfmt %<CR>
augroup END


augroup QuickFix
    " override :YcmComplete GoTo for QF
    au FileType qf nmap <buffer> <CR> <CR>
augroup END
" }}} Autocommands

" {{{ Custom Functions
function! s:FixFileFormat()
    let ff = &fileformat
    if ff == "dos"
        silent exec "!unix2dos \"".expand("%:p")."\""
    else
        silent exec "!dos2unix \"".expand("%:p")."\""
    endif
endfunction
com! FixFileFormat call s:FixFileFormat()

function! s:Verify()
    set list
    let lnr=line('$')

    if lnr%2 != 0
        echom "VERIFY: linenr not multiple of 2 ✗"
        return 0
    endif

    let first_half=getline(0,lnr/2)
    let second_half=getline(lnr/2+1,lnr)
    if first_half !=# second_half
        echom "VERIFY: halfs are different !!! ✗"
        return 1
    else
        call deletebufline(bufnr("%"), 1, '$')
        call append('0', first_half)
        call feedkeys("dd")
        echom "VERIFY: success ✓"
    endif
endfunction
com! Verify call s:Verify()
nmap <leader>vv :Verify<CR>

function! s:OpenTig(...)
    " @TODO show/use .git - dir instead of parent dir of file
    let pdir = expand('%:p:h')
    let toplevel = system('git-show-toplevel-name '.pdir)
    echom "OpenTig ".toplevel
    if exists("a:1")
        silent exec '!urxvt -title "(tig: '.toplevel.')" -cd '.pdir." -e $SHELL -i -c 'tig \"" . a:1 . "\"' &"
    else
        silent exec '!urxvt -title "(tig: '.toplevel.')" -cd '.pdir." -e $SHELL -i -c tig &"
    endif
endfunction
com! -nargs=* OpenTig call s:OpenTig(<args>)

function! s:OpenTerminal()
    let pdir = expand('%:p:h')
    echom "OpenTerminal"
    if g:is_wsl
        silent exec "!wt.exe -w 0 nt wsl.exe --cd ".pdir
    else
        silent exec "!urxvt -cd ".pdir." -e $SHELL -i &"
    endif
endfunction
com! OpenTerminal call s:OpenTerminal()

function! s:GetLink()
    let pos = getcurpos()
    echom system("get-link \"".expand("%:p")."\" \"".pos[1]."\"")
endfunction
com! GetLink call s:GetLink()
nmap <leader>gl :GetLink<CR>

function! s:Path()
    let pos = getcurpos()
    echon system("raf-utils yaml pos \"".expand("%:p")."\" \"".pos[1]."\" \"".pos[2]."\"")
endfunction
com! Path call s:Path()
nmap <leader>pq :Path<CR>

function! CopyCurrentFullTag()
    let @+=tagbar#currenttag("%s", "", "f")
endfunction
map <leader>ct :call CopyCurrentFullTag()<CR>

function! CopySearchRegisterToClipboardRegister()
    let searchreg = @/
    let enclosed = matchlist(searchreg, '^\\V\\<\(.*\)\\>')
    if len(enclosed) > 0
        let searchreg = enclosed[1]
    endif

    " copy to clipboard
    let @+=searchreg
endfunction
map <leader>x :call CopySearchRegisterToClipboardRegister()<CR>

function! s:ToggleLRWindow(...)
    " @TODO if current window is not actualFile, try going to last window first, given that its a normal file window
    func! s:isWindowWithActualFile(nr) closure
        " we test if the buftype of the buffer of the window is empty, which is only true for normal files
        let btype = getbufvar(winbufnr(a:nr), '&buftype', 'ERROR')
        if btype == ""
            return 1
        endif
        return 0
    endfunc

    let currentwinnr = winnr()
    let totalwinnr = winnr('$')
    let i = 1

    while i <= totalwinnr
        if i != currentwinnr
            if s:isWindowWithActualFile(i)
                " jump to window with winnr i
                exe i . "wincmd w"
                return
            endif
        endif 
        let i += 1
    endwhile
endfunction
com! -nargs=* ToggleLRWindow call s:ToggleLRWindow(<f-args>)
if &diff
    nmap <silent> <C-l> :ToggleLRWindow<CR>
endif

function! s:Mark(...)
    let pos = getcurpos()
    " echo 
    " call writefile([expand("%:p").":".pos[1].":".pos[4]], "/tmp/credit", "a")
    " call execute("mark-code -o '".expand("%:p").":".pos[1].":".pos[4]."'")
    echom system("mark-code ".expand("%:p").":".pos[1].":".pos[4]." ".join(a:000))
endfunction
com! -nargs=+ Mark call s:Mark(<f-args>)

function! s:AddBreakp(...)
    let pos = getcurpos()
    echom system("add-breakpoint ".expand("%:p").":".pos[1])
endfunction
com! -nargs=* AddBreakp call s:AddBreakp(<f-args>)

function! s:OpenInVsCode(...)
    let pos = getcurpos()
    echom system("code "."--goto \"".expand("%:p").":".pos[1].":".pos[4]."\"")
endfunction
com! OpenInVsCode call s:OpenInVsCode()

"" chmods executable bit if write creates new file
function! s:AddExecutablebitPre()
    if !filereadable(expand('%')) && getline(1) =~ "^#!.*/bin/"
        let b:post_chmod_x = 1 
    endif
endfunction
function! s:AddExecutablebitPost()
    if get(b:, 'post_chmod_x', 0) 
        silent execute '!chmod +x %' 
    endif
endfunction

"" strips newline at end if exists
function! s:StripEndingNewline(line)
    let EndChar = a:line[strlen(a:line)-1]
    if EndChar != "\n"
        return a:line
    endif

    return a:line[:-2]
endfunction

"" adds newline at end if not exists
function! s:AddEndingNewline(line)
    let EndChar = a:line[strlen(a:line)-1]
    if EndChar == "\n"
        return a:line
    endif

    return a:line."\n"
endfunction

function! s:SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
com! SynStack call s:SynStack()

function! ClipboardPasteAsNewline()
    " let @a = s:AddEndingNewline(@+)

    let IsFirstLineAndEmpty = line('.') == 1 && getline('.') == ""
    if IsFirstLineAndEmpty
        let @a = s:StripEndingNewline(@+)
        normal! "aP
    else
        let @a = s:AddEndingNewline(@+)
        normal! "ap
    endif
endfunction

function! ClipboardPasteInline()
    let @a = s:StripEndingNewline(@+)
    normal! "ap
endfunction

function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction

command! -nargs=1 ChangeLang
\ execute "bd!|e" substitute(expand("%:p"), "/de/\\\|/en/\\\|/fr/\\\|/it/", "/".<q-args>."/", "")

command! -bar -range=% Reverse <line1>,<line2>g/^/m<line1>-1|nohl

" function! GoogleWordUnderCursor()
"     let wordUnderCursor = expand("<cword>")
"     call system("chromium \"http://www.google.com/search?q=".wordUnderCursor."\"")
"     " echo wordUnderCursor
" endfunction
" nmap <leader>gg :call GoogleWordUnderCursor()<CR>
" nmap <leader>gg :system("chromium \"http://www.google.com/search?q=".wordUnderCursor.<cword>")<CR>

"" toggle characters at the end of a line
function! ToggleLastChar(char)
    let line = getline(".")
    if line[len(line)-1] == a:char
       call setline( ".", strpart(line, 0, len(line)-1) )
    else
       call setline( ".", line . a:char )
    endif
endfunction
nmap <leader>, :call ToggleLastChar(",")<CR>
nmap <leader>. :call ToggleLastChar(";")<CR>

function! s:Escape(startl, endl) range
    " TODO
    let n = @n
    silent! normal gv"ny
    echo "Word count:" . system("echo '" . @n . "' | wc -w")
    let @n = n
    " bonus: restores the visual selection
    normal! gv
endfunction
com! -range Escape call s:Escape(<line1>,<line2>)

"" show changes between current buffer and last saved version
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! ToggleSpacesAroundParens()
    " TODO
    let cur_cur_pos = getpos(".")
    let cur_cur_pos[2]=0

    " CASES:
    " 1. is on a paren
    " 2.

    " Store current-cursor-pos in curpos

    " Search backwards from pos for '(' store it in lpp
    " If it couldnt, just stop

    " If character after lpp is a space {
    "    Search backwards from pos for '(' store it in lpp
    " }

    " If character after lpp is not a space {
    "
    " }
    call setpos(".", cur_cur_pos)
endfunction

let s:__attempt_cd_git_cache = 0
function! s:AttemptToCdToGitDir()
    let cf  = expand("%:p")

    " if file startswith /tmp/agt → disable
    let agtprefix="/tmp/agt"
    if (expand("%")[0:len(agtprefix)-1] ==# agtprefix) || (expand("%") ==# "")
        let s:__attempt_cd_git_cache = 1
        return
    endif

    if s:__attempt_cd_git_cache == 1
        return
    endif
    let s:__attempt_cd_git_cache = 1

    let cgd = trim(system("git rev-parse --show-toplevel"))
    if v:shell_error != 0
        return
    endif

    if getcwd() != cgd
        echom cgd
        exe 'cd' cgd
    endif
endfunction
autocmd BufReadPost,BufFilePost,StdinReadPost * call s:AttemptToCdToGitDir()

function! s:ToggleCD()
    let cwd = getcwd()
    let cf  = expand("%:p")
    let cfd = expand("%:p:h")
    let cgd = trim(system("git rev-parse --show-toplevel"))
    if v:shell_error != 0
        echo "No GIT dir."
    endif

    if cwd != cgd
        echom "cd ".cgd." (git)"
        exe 'cd' cgd
    else
        echom "cd ".cfd
        exe 'cd' cfd
    endif
endfunction
com! ToggleCD call s:ToggleCD()
nnoremap <leader>sd :ToggleCD<CR>

nnoremap <leader>ss :lua ExchangeBufferWithClipboard()<CR>

lua << EOF
function ExchangeBufferWithClipboard()
  local buf_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local buf_text = table.concat(buf_content, "\n")
  local clipboard = vim.fn.getreg('+')

  local msg = ""
  if buf_text == clipboard then
    -- vim.api.nvim_echo({{"Buffer is identical to clipboard.", "None"}}, false, {})
    msg = "Buffer was identical to clipboard."
  else
    -- Replace buffer with clipboard
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(clipboard, "\n"))
    msg = "Buffer was replaced with clipboard content."
  end

  vim.cmd('write')
  vim.api.nvim_echo({{msg, "None"}}, false, {})

end
EOF

"" ??-?? forgot what this does
function! EditJsonKVInLine(key)
    let cur_cur_pos = getpos(".")
    let cur_cur_pos[2]=0
    call setpos(".", cur_cur_pos)

    let line = getline(".")
    let lineme = matchend(line, a:key)
    if (lineme < 0)
        let cur_line = getline(".")
        call setline(".", cur_line." \"".a:key."\": \"\",")
        sleep 10m
    endif

    let line = getline(".")
    let lineme = matchend(line, a:key)
    let cur_cur_pos[2]=lineme+5
    call setpos(".", cur_cur_pos)

    normal! di"

    let line = getline(".")
    let lineme = matchend(line, a:key)
    let cur_cur_pos[2]=lineme+5
    call setpos(".", cur_cur_pos)

    " normal! l
    startinsert
endfunction

function! CopyPathToClip()
    echo "Copying path to clipboard..."
    call setreg("+", expand("%:p"))
    call setreg("*", expand("%:p"))
endfunction
nmap <leader>pc :call CopyPathToClip()<CR>
nmap <leader>pp :call CopyPathToClip()<CR>
function! CopyFileNameToClip()
    echo "Copying filename to clipboard..."
    call setreg("+", expand("%:t:r"))
    call setreg("*", expand("%:t:r"))
endfunction
nmap <leader>pf :call CopyFileNameToClip()<CR>
nmap <leader>gf :call CopyFileNameToClip()<CR>
nmap <leader>py :call CopyPathToClip()<CR>

function! CopyRelativePathWLineToClip()
    echo "Copying relative path w/ linenr to clipboard..."
    let path_to_file = expand("%:p")
    let svn_working_copy = system("svnrootdir \"" . path_to_file . "\"")
    " chomp newline and add a tralining '/'
    let svn_working_copy = substitute(svn_working_copy, "\n", "/", "")

    let relative_path = substitute(path_to_file, svn_working_copy, "", "g")
    let current_line_number = line(".")
    " echo "\"".svn_working_copy."\""
    " echo "\"".path_to_file."\""

    let result = relative_path . ":" . current_line_number
    call setreg("+", result)
    call setreg("*", result)

endfunction
nmap <silent> <leader>pr :call CopyRelativePathWLineToClip()<CR>

function! DuplicateLineBelowAndJumpToSameCursorPositionOnIt()
    let cur_cur_pos = getpos(".")
    let cur_cur_pos[1] += 1

    normal! yyp

    call setpos(".", cur_cur_pos)
endfunction
nmap <leader>y :call DuplicateLineBelowAndJumpToSameCursorPositionOnIt()<CR>

" ??-??
nmap <leader>< :s/^\s\+//e<CR>:nohl<CR>

" ??-??
fu! s:Split()
    execute ":s/|/\r/g"
endfunction
com! Split call s:Split()

" {{{ vuild
" requires:
"     skywind3000/asyncrun.vim
func s:vuildSaveAndRun(cmd)
    if @% != ""
        execute ":w"
    else
        execute ":w! /tmp/vuild.tmp"
    endif

    execute ":AsyncRun -raw ".a:cmd
endf

func! s:vuildRun()
    " stop already potential running process
    if g:asyncrun_status == "running"
        execute ":AsyncStop!"
        " for it to quit
        while g:asyncrun_status == "running"
            sleep 200m
        endwhile
    endif 

    " RUN lines always take priority
    let i = 0
    while i < 22
        let line=getline(i)
        let induceResult=matchlist(line, '^\A\+\[RUN\]\s*\(.*\)') " regex: start-of-string, one-and-more-non-alphabetic-chars,[RUN],any-whitespaces,group-0-any
        if !empty(induceResult)
            let cmd = get(induceResult, 1)
            call s:vuildSaveAndRun(cmd)
            return 0
        endif

        let i += 1
    endwhile

    " if no explicitly set RUN was found, run something depending on syntax
    let filetype = &filetype
    if filetype == "nim"
        call s:vuildSaveAndRun("nim c -r %")
    elseif filetype == "c"
        call s:vuildSaveAndRun("gcc -o /tmp/tmp_out_gcc % && /tmp/tmp_out_gcc")
    elseif filetype == "cpp"
        call s:vuildSaveAndRun("g++ -o /tmp/tmp_out_g++ % && /tmp/tmp_out_g++")
    elseif filetype == "python"
        call s:vuildSaveAndRun("python %")
    elseif filetype == "lua"
        call s:vuildSaveAndRun("lua %")
    elseif filetype == "html"
        call s:vuildSaveAndRun("chromium %")
    elseif filetype == "go"
        " check if file ends with `_test`
        if expand("%:r") =~ "_test" 
            let l:currentTag = tagbar#currenttag('[%s] ','')[1:-5]
            execute 'cd' fnameescape(expand("%:p:h"))
            call s:vuildSaveAndRun("go test -run ".fnameescape(expand("%:p")))
        else
            call s:vuildSaveAndRun("go run %")
        endif
    elseif filetype == "elixir"
        call s:vuildSaveAndRun("elixir %")
    elseif filetype == "groovy"
        call s:vuildSaveAndRun("groovy %")
    elseif filetype == "perl"
        call s:vuildSaveAndRun("perl %")
    elseif filetype == "javascript"
        call s:vuildSaveAndRun("node %")
    elseif filetype =~ "yaml.*"
        call s:vuildSaveAndRun("yq -oj -P . '%'")
    elseif filetype == "json"
        call s:vuildSaveAndRun("jq . '%'")
    else
        call s:vuildSaveAndRun("./%")
    endif
endf

com! Run
\ call s:vuildRun()
" }}}

"" atm. this is no jinja template, instead we just source a file mb defined locally, might change
call SourceIfExists("~/.config/nvim/local_custom_functions")
" }}} Custom Functions

" {{{ Colors/Highlight
highlight yamlBlockMappingKey          cterm=none ctermfg=11 ctermbg=none
highlight yamlFlowMappingKey           cterm=none ctermfg=11 ctermbg=none
highlight yamlFlowIndicator            cterm=none ctermfg=14 ctermbg=none
highlight yamlDocumentStart            cterm=none ctermfg=16 ctermbg=none
highlight yamlDocumentEnd              cterm=none ctermfg=16 ctermbg=none
highlight yamlKeyValueDelimiter        cterm=none ctermfg=14 ctermbg=none
highlight yamlFlowMapping              cterm=none ctermfg=14 ctermbg=none
highlight yamlBlockCollectionItemStart cterm=none ctermfg=16 ctermbg=none
highlight yamlAlias                    cterm=none ctermfg=13 ctermbg=none
highlight yamlAnchor                   cterm=none ctermfg=17 ctermbg=none
highlight yamlNodeTag                  cterm=none ctermfg=12 ctermbg=none

highlight jsonBraces             cterm=none ctermfg=14 ctermbg=none
highlight jsonTrailingCommaError cterm=none ctermfg=1  ctermbg=none
highlight jsonMissingCommaError  cterm=none ctermfg=1  ctermbg=none
highlight jsonNoQuotesError      cterm=none ctermfg=1  ctermbg=none

highlight jinjaVarDelim  cterm=none ctermfg=17 ctermbg=none
highlight jinjaTagDelim  cterm=none ctermfg=17 ctermbg=none
highlight jinjaVariable  cterm=none ctermfg=16 ctermbg=none
highlight jinjaOperator  cterm=none ctermfg=11 ctermbg=none
highlight jinjaFilter    cterm=none ctermfg=4  ctermbg=none
highlight jinjaStatement cterm=none ctermfg=5  ctermbg=none
highlight jinjaString    cterm=none ctermfg=2  ctermbg=none

" highlight Search cterm=none ctermfg=19 ctermbg=yellow
highlight Search cterm=none ctermfg=black ctermbg=yellow
" }}} Colors/Highlight

" {{{ Plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

" Features
Plug 'scrooloose/nerdtree'
Plug 'godlygeek/tabular'
Plug 'junegunn/vim-easy-align'
Plug 'Raimondi/delimitMate'
Plug 'nathanaelkane/vim-indent-guides'

" Plug 'sgur/vim-editorconfig'
Plug 'editorconfig/editorconfig-vim'
Plug 'skywind3000/asyncrun.vim'

" Plug 'Valloric/YouCompleteMe', { 'commit': '2d1de481a94a3be428c87ab0404c38e58b386813' }
Plug 'ycm-core/YouCompleteMe'
" Plug 'scrooloose/syntastic'
Plug 'Rafflesiaceae/ale'
Plug 'Rafflesiaceae/vim-yaml'
" Plug 'dansomething/vim-eclim' ,{ 'for': ['java', 'php']}
Plug 'majutsushi/tagbar'

if has('python3')
    Plug 'SirVer/ultisnips'
    Plug 'Rafflesiaceae/vim-snippets'
endif

" Plug 'rhysd/vim-grammarous'
Plug 'rhysd/vim-grammarous' ,{ 'on': 'GrammarousCheck'}
Plug 'bfredl/nvim-miniyank'

Plug 'chrisbra/Colorizer'   ,{ 'on': 'ColorToggle'}

Plug 'EinfachToll/DidYouMean'
Plug 'tommcdo/vim-exchange'

" Beauty
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mhinz/vim-startify'

" Movements
Plug 'justinmk/vim-sneak'
Plug 'farmergreg/vim-lastplace'
" Plug 'dyng/ctrlsf.vim'

if s:os == "Darwin"
    Plug '/usr/local/opt/fzf'
else
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
endif

Plug 'dyng/ctrlsf.vim'
Plug 'PeterRincker/vim-argumentative'

" SCM
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Tpope
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
" Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-ragtag'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-jdaddy'


" Languages
" Plug 'jelera/vim-javascript-syntax'
" Plug 'othree/yajs.vim'
" Plug 'neoclide/vim-jsx-improve'
Plug 'leafgarland/typescript-vim'
Plug 'pangloss/vim-javascript'
Plug 'heavenshell/vim-jsdoc'
Plug 'maxmellon/vim-jsx-pretty'
" Plug 'edwinb/idris-vim'
" Plug 'mitsuhiko/vim-python-combined' ,{ 'for': 'python'  }
Plug 'Rafflesiaceae/vim-py-indent',         { 'for': 'python,starlark' }
Plug 'Rafflesiaceae/vim-xml-indent'
" Plug 'python-rope/ropevim'
" Plug 'vim-scripts/DoxyGen-Syntax'

Plug 'fatih/vim-go'
" Plug 'flyinshadow/php_localvarcheck.vim' ,{ 'for': 'php' }
Plug 'lifepillar/pgsql.vim'                ,{ 'for': 'sql' }
" Plug 'modille/groovy.vim'                ,{ 'for': 'groovy' }

Plug 'zah/nim.vim'                 ,{ 'for': 'nim' }
Plug 'ericcurtin/CurtineIncSw.vim' ,{ 'for': 'cpp' }
Plug 'leafo/moonscript-vim'        ,{ 'for': 'moon' }
" Plug 'ziglang/zig.vim'             ,{ 'for': 'zig' }

Plug 'slashmili/alchemist.vim'   ,{ 'for': 'ex' }
Plug 'elixir-editors/vim-elixir' ,{ 'for': 'ex' }

Plug 'spacewander/openresty-vim'
Plug 'nickhutchinson/vim-systemtap'

Plug 'rhysd/conflict-marker.vim'

" Plug 'tpope/vim-sexp-mappings-for-regular-people'
" Plug 'guns/vim-sexp'

" Markups
Plug 'mustache/vim-mustache-handlebars'
Plug 'shime/vim-livedown'               ,{ 'for': 'markdown' }
Plug 'martinda/Jenkinsfile-vim-syntax'
" Plug 'MikeCoder/markdown-preview.vim'
" Plug 'gu-fan/riv.vim'
Plug 'pboettch/vim-cmake-syntax'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'pearofducks/ansible-vim'
Plug 'jigish/vim-thrift'
Plug 'mitei/gyp.vim'                    ,{ 'for': 'gyp' }
Plug 'gutenye/json5.vim'
Plug 'elzr/vim-json'
Plug 'cappyzawa/starlark.vim'           ,{ 'for': 'starlark' }
Plug 'saltstack/salt-vim'
Plug 'zchee/vim-flatbuffers'
Plug 'cespare/vim-toml'
Plug 'LnL7/vim-nix'
Plug 'Rafflesiaceae/vim-prometheus'
Plug 'Rafflesiaceae/vim-gta2'
Plug 'michaeljsmith/vim-indent-object'
Plug 'jvirtanen/vim-hcl', { 'commit': '1e1116c17a5774851360ea8077f349e36fc733c1' }
Plug 'earthly/earthly.vim', { 'commit': 'cb0440a357a09fb9234ece56a6b09e04d25c1b1d' }

Plug 'wsdjeg/vim-fetch'

Plug 'will133/vim-dirdiff'
Plug 'AndrewRadev/linediff.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'LhKipp/nvim-nu'

call SourceIfExists("~/.config/nvim/local_custom_imports")

call plug#end()
" }}} Plugins

" Autocommands (Postplugged)

au BufRead,BufNewFile *.jsonl set filetype=plain

au BufRead,BufNewFile *.containerfile set filetype=dockerfile
au BufRead,BufNewFile *.Containerfile set filetype=dockerfile

" jinja
au BufRead,BufNewFile *.cfg.j2 set filetype=cfg.jinja2
au BufRead,BufNewFile *.html.j2 set filetype=html.jinja2
au BufRead,BufNewFile *.json.j2 set filetype=jinja2
au BufRead,BufNewFile *.service.j2 set filetype=systemd.jinja2
au BufRead,BufNewFile *.xml.j2 set filetype=xml.jinja2
au BufRead,BufNewFile *.yml.j2 set filetype=yaml.jinja2
autocmd FileType jinja setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

" {{{ typescript / tsc
au BufRead,BufNewFile tsconfig.json set filetype=json5 syntax=json5
au FileType starlark set filetype=starlark.python
" }}}
" {{{ PKGBUILD 
autocmd BufRead,BufNewFile PKGBUILD set filetype=sh
" }}}
" {{{ Helm Syntax 
function HelmSyntax()
  set filetype=yaml
  unlet b:current_syntax
  syn include @yamlGoTextTmpl syntax/gotexttmpl.vim
  let b:current_syntax = "yaml"
  syn region goTextTmpl start=/{{/ end=/}}/ contains=@gotplLiteral,gotplControl,gotplFunctions,gotplVariable,goTplIdentifier containedin=ALLBUT,goTextTmpl keepend
  hi def link goTextTmpl PreProc
endfunction
augroup helm_syntax
  autocmd!
  autocmd BufRead,BufNewFile */templates/*.yaml,*/templates/*.tpl call HelmSyntax()
augroup END
" }}}

" {{{ yml.j2
au BufRead,BufNewFile *.yml.j2 set filetype=ansible
au BufRead,BufNewFile *.xml.j2 set filetype=xml.jinja2
au BufRead,BufNewFile *.cfg.j2 set filetype=cfg.jinja2
" }}}

" " disable indent
" set noautoindent
" set indentexpr=
" set nocindent
" set nosmartindent

" @XXX @WORKAROUND
" fixup for editorconfig-vim on neovim 
" see https://github.com/editorconfig/editorconfig-vim/issues/163
augroup _editorconfig
autocmd BufEnter * :EditorConfigReload
augroup END

" hi SpecialKey ctermfg=9 guifg=161
" highlight SpecialKey cterm=none ctermfg=16 ctermbg=18 gui=none guifg=bg guibg=Red
" highlight NonText ctermfg=102
" highlight NonText ctermfg=59
highlight NonText ctermfg=19
" autocmd BufRead,BufNewFile *.anic setlocal commentstring=//\ %s 

" neovim >=0.10 fixes
" hi Visual ctermfg=NONE
" " hi MatchParen ctermfg=NONE
" hi MatchParen cterm=bold,underline ctermfg=0 ctermbg=8
syn region cPragma start="^\s*#pragma\s\+region\>" end="^\s*#pragma\s\+endregion\>" transparent fold


" {{{ Split lines in visual selection accord go delims/whitespace to newlines
" Define function to split lines by whitespace and delimiters
function! SplitVisualSelection()
    " Save current selection
    let save_reg = @"
    let save_view = winsaveview()

    " Get visual selection as a list of lines
    execute "normal! gv\"zy"
    let lines = split(@z, "\n")

    " Define delimiters to split on
    let delimiters = '[[:space:]()"''{}[\]]\+'

    " Process each line
    let result = []
    for line in lines
        " Split line into words using delimiters
        let words = split(line, delimiters)
        " Append words as separate lines
        call extend(result, words)
    endfor

    " Replace selection with newlines between words
    execute "normal! gv\"_d"  
    " Delete selection silently
    call append(getpos("'<")[1] - 1, result)

    " Restore cursor position
    call winrestview(save_view)

    " Restore original register
    let @" = save_reg
endfunction

" Bind function to <leader>S in visual mode
vnoremap <leader>sp :<C-u>call SplitVisualSelection()<CR>

" }}} Fix NeoVim Colorscheme BS
" https://www.ditig.com/256-colors-cheat-sheet
" highlight ctrlsfFile guifg=#a0a0a0 guibg=#000000 ctermfg=0 ctermbg=1
" highlight MatchParen cterm=bold ctermfg=0 ctermbg=7 gui=bold guifg=#2d2d2d guibg=#747369                                                                              
" highlight MatchParen cterm=bold ctermfg=none ctermbg=7 gui=bold guifg=#2d2d2d guibg=#747369
" highlight MatchParen cterm=bold ctermfg=none ctermbg=101
" highlight MatchParen cterm=bold ctermfg=none ctermbg=241
" highlight MatchParen cterm=bold ctermfg=0 ctermbg=1
" highlight Visual ctermfg=none ctermbg=238
" highlight Visual ctermfg=none ctermbg=19
" highlight Visual ctermfg=none ctermbg=101
" highlight ctrlsfFile ctermfg=5
" highlight Visual ctermfg=none ctermbg=238
" highlight MatchParen cterm=none ctermfg=none ctermbg=243
highlight Visual ctermfg=none ctermbg=239
highlight MatchParen cterm=none ctermfg=none ctermbg=245
" highlight MatchParen cterm=none ctermfg=none ctermbg=218
" highlight MatchParen cterm=none ctermfg=none ctermbg=220
" highlight MatchParen cterm=none ctermfg=none ctermbg=215
" highlight MatchParen cterm=none ctermfg=none ctermbg=184
" highlight MatchParen cterm=none ctermfg=none ctermbg=178
" {{{ Fix NeoVim Colorscheme BS

" {{{ Setup NU Treesitter stuff
lua require('treesitter-nu')
