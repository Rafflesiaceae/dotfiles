scriptencoding utf-8
" {{{ 🔨 Core options
function! SourceIfExists(file) abort
    let l:path = expand(a:file)
    if filereadable(l:path)
        execute "source " . fnameescape(l:path)
    endif
endfunction

" Runtime compatibility ----------------------------------------------------
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

let g:is_wsl = !empty($WSL_INTEROP)

if filereadable('/etc/vimrc')
    source /etc/vimrc
endif

" WSL writes must consistently use Unix line endings.
if g:is_wsl
    function! Dos2Unix() abort
        let l:view = winsaveview()
        setlocal fileformat=unix
        silent! keeppatterns %s/\r//ge
        call winrestview(l:view)
    endfunction

    augroup user_wsl_line_endings
        autocmd!
        autocmd BufWritePre * call Dos2Unix()
    augroup END
endif

" General editing ---------------------------------------------------------
let mapleader = ","
let g:mapleader = ","

set nocompatible
filetype off
set autoindent breakindent
set backup backupdir=$HOME/.vim/backup
set clipboard^=unnamed
set foldlevel=99 foldmethod=marker
set formatoptions-=t
set iskeyword=@,48-57,_,192-255
set matchpairs+=<:>
set maxmempattern=8192
set number relativenumber
set scrollback=100000 scrollopt+=hor
set showcmd showbreak=↪
set splitright
set textwidth=80
set timeoutlen=250
set title titlelen=70
set ttimeoutlen=0
set wildcharm=<Tab>
set mousemodel=popup
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor

if g:is_wsl
    set ttimeoutlen=5 fileformat=unix
endif

" Shift-Tab in terminals that do not advertise the key correctly.
set t_kB=^[[Z

" Appearance --------------------------------------------------------------
let base16colorspace=256
set background=dark
colorscheme base16-kokonai

" Avoid rescanning syntax on every BufEnter. The Syntax event runs only when
" syntax is initialized, and maxlines caps work for very large buffers.
augroup user_core_events
    autocmd!
    autocmd FilterWritePre * if &diff | setlocal wrap< | endif
    autocmd Syntax * syntax sync minlines=256 maxlines=1000
augroup END

" }}} 🔨 Core options
" {{{ 🔌 Plugin settings
" Configurations
let NERDTreeQuitOnOpen=1
" {{{ NeoVim
let g:editorconfig = v:false
" }}}
" {{{ YouCompleteMe
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
let g:ycm_gopls_binary_path = $HOME . '/.go/bin/gopls'

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
  \   {
  \     'name': 'jenkins',
  \     'cmdline': [ 'java', '-jar', $HOME.'/workspace/jenkins-lsp/target/jenkins-lsp-1.0.0-all.jar', '--stdio' ],
  \     'filetypes': ['jenkins', 'groovy'],
  \   },
  \ ]
  " \   {
  " \     'name': 'groovy',
  " \     'cmdline': [ 'java', '-jar', '/usr/share/java/groovy-language-server/groovy-language-server-all.jar' ],
  " \     'filetypes': [ 'groovy', 'gvy', 'gy', 'gsh' ],
  " \   }

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
" {{{ EditorConfig
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
" {{{ Airline
let g:airline_highlighting_cache = 1
"let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#ale#enabled = 0
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#nvimlsp#enabled = 0
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
" {{{ UltiSnips
let g:UltiSnipsExpandTrigger="<C-l>"
let g:UltiSnipsJumpForwardTrigger="<C-l>"
let g:UltiSnipsJumpBackwardTrigger="<C-o>"
let g:UltiSnipsUsePythonVersion = 3
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
    augroup user_ack_quickfix
        autocmd!
        autocmd QuickFixCmdPost *grep* cwindow
    augroup END
endif
let g:ack_use_dispatch = 1
" }}}
" {{{ Colorizer
let g:colorizer_auto_filetype='css,html,text'
" }}}
" {{{ CtrlSF
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
" {{{ Tagbar
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
" {{{ Indent Guides
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
" {{{ AsyncRun
" Automatically open QF when running a cmd
augroup user_asyncrun_quickfix
    autocmd!
    autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
augroup END
" }}}
" {{{ Automatically close quickfix
augroup user_quickfix_close
    au!
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix"|q|endif
augroup END
" }}}
" {{{ Quickfix size
" au FileType qf call AdjustWindowHeight(20, 10)
" function! AdjustWindowHeight(minheight, maxheight)
"   exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
" endfunction
" }}}
" {{{ fzf layout
" let g:fzf_preview_window = ['right:50%', 'ctrl-/']
" let g:fzf_layout = { 'down': '40%' }
" }}}
" {{{ ansible-vim
let g:ansible_unindent_after_newline = 1
" }}}
" {{{ Grammarous
let g:grammarous#jar_url = 'https://www.languagetool.org/download/LanguageTool-5.9.zip'
" }}}


" }}} 🔌 Plugin settings
" {{{ 📦 Plugin declarations
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

" Features
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeFind', 'NERDTreeClose'] }
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
    " Starting the Python provider dominated startup (~100 ms). Load snippets
    " on the first insert instead; no snippet functionality is lost.
    Plug 'SirVer/ultisnips',          { 'on': [] }
    Plug 'Rafflesiaceae/vim-snippets', { 'on': [] }
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

if has('macunix')
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
" Plug 'Rafflesiaceae/vim-py-indent'
" Plug 'Rafflesiaceae/vim-xml-indent'
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

Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main', 'do': ':TSUpdate'}
Plug 'LhKipp/nvim-nu'

call SourceIfExists("~/.config/nvim/local_custom_imports")

call plug#end()

if has('python3')
    augroup user_lazy_ultisnips
        autocmd!
        autocmd InsertEnter * ++once call plug#load('ultisnips', 'vim-snippets')
    augroup END
endif
" }}} 📦 Plugin declarations
" {{{ 🧰 Commands and functions
" {{{ Clipboard and selection helpers
function! CopyLineToClipboard()
    let l:line = getline('.')

    " Try to match and extract using Vim regex
    let l:matches = matchlist(l:line, '\v^([^:]+):\s*(.+)$')
    let l:input = v:null
    let l:msg = ""
    if len(l:matches) >= 3
        " Group 2 is at index 2
        let l:input = l:matches[2]
        let l:msg = "Line (key:val) copied to clipboard: '" . l:matches[2] . "'"
    else
        let l:input = l:line
        let l:msg = "Line copied to clipboard: '" . l:line . "'"
    endif


    if l:input isnot v:null && l:input !=# '' && l:input =~# '\S'
        " l:input is valid (not null, not empty, not just whitespace)
        let @+ = l:input
        echo l:msg
    else
        echo ''
    endif
endfunction
nnoremap <silent> <3-LeftMouse> :call CopyLineToClipboard()<cr>:set nohls<cr>

function! s:ExpandAuto(...)
    silent exec ':redir @* | YcmCompleter GetType | redir END'
    " @TODO show/use .git - dir instead of parent dir of file
    " let pdir = expand('%:p:h')
    " let toplevel = system('git-show-toplevel-name '.pdir)
    " echom "OpenTig ".toplevel
    " if exists("a:1")
    "     silent exec '!urxvt -title "(tig: '.toplevel.')" -cd '.pdir." -e $SHELL -i -c 'tig \"" . a:1 . "\"' &"
    " else
    "     silent exec '!urxvt -title "(tig: '.toplevel.')" -cd '.pdir." -e $SHELL -i -c tig &"
    " endif
endfunction
com! -nargs=* ExpandAuto call s:ExpandAuto(<args>)

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

function! s:OpenTig(...) abort
    let l:directory = expand('%:p:h')
    let l:git_root = s:FindGitRoot(l:directory)
    let l:title = '(tig: ' . (empty(l:git_root) ? l:directory : l:git_root) . ')'
    let l:command = a:0 ? 'tig ' . shellescape(a:1) : 'tig'
    call jobstart([
          \ 'urxvt', '-title', l:title, '-cd', l:directory,
          \ '-e', $SHELL, '-i', '-c', l:command,
          \ ], {'detach': v:true})
endfunction
com! -nargs=* OpenTig call s:OpenTig(<args>)

function! s:OpenTerminal() abort
    let l:directory = expand('%:p:h')
    if g:is_wsl
        call jobstart(['wt.exe', '-w', '0', 'nt', 'wsl.exe', '--cd', l:directory], {'detach': v:true})
    else
        call jobstart(['urxvt', '-cd', l:directory, '-e', $SHELL, '-i'], {'detach': v:true})
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

function! s:OpenInVsCode() abort
    let l:position = getcurpos()
    let l:target = printf('%s:%d:%d', expand('%:p'), l:position[1], l:position[4])
    call jobstart(['code', '--goto', l:target], {'detach': v:true})
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
        let l:path = expand('%:p')
        let l:permissions = getfperm(l:path)
        if len(l:permissions) == 9
            let l:permissions = l:permissions[0:1] . 'x'
                  \ . l:permissions[3:4] . 'x'
                  \ . l:permissions[6:7] . 'x'
            call setfperm(l:path, l:permissions)
        endif
        unlet b:post_chmod_x
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
" }}} Clipboard and selection helpers
" {{{ Generic editing commands
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
    let l:saved_register = @n
    silent! normal gv"ny
    echo 'Word count: ' . len(split(@n))
    let @n = l:saved_register
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

" }}} Generic editing commands
" {{{ Project directory handling
let s:did_attempt_git_cd = 0
function! s:FindGitRoot(path) abort
    let l:dir = isdirectory(a:path) ? a:path : fnamemodify(a:path, ':h')
    let l:marker = finddir('.git', l:dir . ';')
    if empty(l:marker)
        let l:marker = findfile('.git', l:dir . ';')
    endif
    if empty(l:marker)
        return ''
    endif
    let l:absolute_marker = substitute(fnamemodify(l:marker, ':p'), '/\+$', '', '')
    return fnamemodify(l:absolute_marker, ':h')
endfunction

function! s:AttemptToCdToGitDir() abort
    let l:file = expand('%:p')
    if empty(l:file) || l:file =~# '^/tmp/agt'
        let s:did_attempt_git_cd = 1
        return
    endif

    if s:did_attempt_git_cd
        return
    endif
    let s:did_attempt_git_cd = 1

    let l:git_root = s:FindGitRoot(l:file)
    if empty(l:git_root)
        return
    endif

    if getcwd() !=# l:git_root
        echom l:git_root
        execute 'cd ' . fnameescape(l:git_root)
    endif
endfunction

function! s:ToggleCD() abort
    let l:file_dir = expand('%:p:h')
    let l:git_root = s:FindGitRoot(l:file_dir)
    if empty(l:git_root)
        echo "No GIT dir."
        return
    endif

    if getcwd() !=# l:git_root
        echom 'cd ' . l:git_root . ' (git)'
        execute 'cd ' . fnameescape(l:git_root)
    else
        echom 'cd ' . l:file_dir
        execute 'cd ' . fnameescape(l:file_dir)
    endif
endfunction
com! ToggleCD call s:ToggleCD()
nnoremap <leader>sd :ToggleCD<CR>
" }}} Project directory handling
" {{{ Path and line helpers
function! CopyPathToClip()
    echo "Copying path to clipboard..."
    call setreg("+", expand("%:p"))
    call setreg("*", expand("%:p"))
endfunction
nmap <leader>pc :call CopyPathToClip()<CR>
nmap <leader>pl :let @+ = expand('%:p') . ':' . line('.') . ':' . col('.')<CR>
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
" }}} Path and line helpers
" {{{ Plugin helpers
function! s:ToggleNERDTree() abort
    if exists('g:NERDTree') && g:NERDTree.IsOpen()
        NERDTreeClose
    elseif bufexists(expand('%'))
        NERDTreeFind
    else
        NERDTree
    endif
endfunction
" }}} Plugin helpers
" {{{ Autoversion
function! s:RunAutoversion()
    if &modified
        echoerr "Please save or discard changes before running :Autoversion."
        return
    endif

    let l:filename = expand('%:p')
    if empty(l:filename)
        echoerr "No file path detected."
        return
    endif

    let l:cmd = 'autoversion ' . shellescape(l:filename)

    " Set up an autocmd to reload the buffer after AsyncRun finishes
    augroup AutoversionReload
        autocmd!
        autocmd User AsyncRunStop ++once call s:ReloadCurrentBuffer()
    augroup END

    execute ":AsyncRun -raw " . l:cmd
endfunction

function! s:ReloadCurrentBuffer() abort
    " Safe because s:RunAutoversion refuses to run with unsaved changes.
    silent! edit!
    echo "Buffer reloaded after autoversion."
endfunction

command! Autoversion call <SID>RunAutoversion()
" }}}
" {{{ AutoReload
let g:auto_reload_enabled = 0

function! ToggleAutoReload() abort
    if g:auto_reload_enabled
        echo "AutoReload already enabled (can't disable atm., just restart)"
        return
    endif

    let g:auto_reload_enabled = 1
    augroup AutoReload
        autocmd!
        autocmd FocusGained,BufEnter * checktime
    augroup END
    echo "AutoReload enabled"
endfunction

command! AutoReload call ToggleAutoReload()
" }}}
" {{{ Build and run
" Requires skywind3000/asyncrun.vim.
function! s:vuildSaveAndRun(cmd) abort
    if !empty(@%)
        write
    else
        write! /tmp/vuild.tmp
    endif
    execute 'AsyncRun -raw ' . a:cmd
endfunction

" Search for build.sh in parent directories
function! s:vuildFindBuildScript() abort
    let l:dir = expand('%:p:h')
    while 1
        let l:build_script = l:dir . '/build.sh'
        if filereadable(l:build_script)
            return l:build_script
        endif
        let l:parent = fnamemodify(l:dir, ':h')
        if l:parent ==# l:dir
            return ''
        endif
        let l:dir = l:parent
    endwhile
endfunction

function! s:vuildRun() abort
    if get(g:, 'asyncrun_status', '') ==# 'running'
        AsyncStop!
        if wait(5000, { -> get(g:, 'asyncrun_status', '') !=# 'running' }, 50) != 0
            echoerr 'Timed out while stopping the previous AsyncRun job.'
            return
        endif
    endif

    " An explicit [RUN] directive in the first 22 lines takes priority.
    for l:line_number in range(1, min([22, line('$')]))
        let l:match = matchlist(getline(l:line_number), '^\A\+\[RUN\]\s*\(.*\)')
        if !empty(l:match)
            call s:vuildSaveAndRun(l:match[1])
            return
        endif
    endfor

    let l:build_script = s:vuildFindBuildScript()
    if !empty(l:build_script)
        call s:vuildSaveAndRun(shellescape(l:build_script))
        return
    endif

    let l:commands = {
          \ 'c': 'gcc -o /tmp/tmp_out_gcc % && /tmp/tmp_out_gcc',
          \ 'cpp': 'g++ -o /tmp/tmp_out_g++ % && /tmp/tmp_out_g++',
          \ 'elixir': 'elixir %',
          \ 'groovy': 'groovy %',
          \ 'html': 'chromium %',
          \ 'javascript': 'node %',
          \ 'json': "jq . '%'",
          \ 'kotlin': 'run-kotlin %',
          \ 'lua': 'lua %',
          \ 'nim': 'nim c -r %',
          \ 'perl': 'perl %',
          \ 'python': 'python %',
          \ }

    if &filetype ==# 'go'
        if expand('%:r') =~# '_test$'
            execute 'cd ' . fnameescape(expand('%:p:h'))
            call s:vuildSaveAndRun('go test -run ' . shellescape(expand('%:p')))
        else
            call s:vuildSaveAndRun('go run %')
        endif
    elseif &filetype =~# '^yaml'
        call s:vuildSaveAndRun("yq -oj -P . '%'")
    elseif has_key(l:commands, &filetype)
        call s:vuildSaveAndRun(l:commands[&filetype])
    else
        call s:vuildSaveAndRun('./%')
    endif
endfunction

com! Run
\ call s:vuildRun()
" }}}

"" atm. this is no jinja template, instead we just source a file mb defined locally, might change
call SourceIfExists("~/.config/nvim/local_custom_functions")
" }}} 🧰 Commands and functions
" {{{ 🔑 Mappings
" {{{ Editing and navigation
" Terminal key constraints: <C-m> is Return; <C-h>/<C-l> switch splits.
map - @
nnoremap Q <Nop>
nmap <F1> <Nop>
imap <F1> <Nop>
noremap 0 ^
noremap ^ 0
nnoremap <leader>sb :windo set scrollbind<CR>

noremap <leader>d :Linediff<CR>

inoremap <M-o> <ESC>o

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
" nnoremap <silent> <3-LeftMouse> :YcmCompleter GoTo<cr>
nnoremap <silent> <leader>h :YcmCompleter GetDoc<cr>
nnoremap <silent> <leader>c :YcmCompleter GoToDeclaration<cr>

nnoremap <silent> <C-n> :call <SID>ToggleNERDTree()<CR>
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
" nnoremap <leader>w :w!<CR>
nnoremap <leader>W :w!<CR>:e!<CR>
nnoremap <leader>l :e!<CR>

inoremap <C-e> <C-o>de
" }}} Editing and navigation
" {{{ Search and refactoring
map <C-g> :CtrlSF
nmap <C-f> :CtrlSF<CR>
vmap <C-f> <Plug>CtrlSFVwordExec<CR>
nmap <leader>f :CtrlSFToggle<CR>
vmap <leader>f <Plug>CtrlSFVwordExec
map <leader>F :YcmCompleter FixIt <CR>

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
" }}} Search and refactoring
" {{{ Buffers and commands
nnoremap <silent> <leader>cf :cd %:p:h<CR>

nnoremap <leader>r :Run<CR>
nmap <leader>o :let @*=expand("%:p")<CR>
map <C-q> :qa!<CR>
" map <C-c> :w<CR>

" handle escape in terminal mode differently
cnoremap <C-a> <Home>

inoremap <C-q> <Esc>:q!<CR>

" <C-a> is INCREASE!!!
" inoremap <C-a> <Esc>:wq!<CR>
" noremap <C-a> :wq!<CR>
" }}} Buffers and commands
" {{{ Clipboard
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
" }}} Clipboard
" {{{ Git and external tools
noremap <leader>gt :OpenTig<CR>
noremap <leader>! :OpenTig<CR>
noremap <leader>" :OpenTig expand("%:p")<CR>
noremap <leader>C :OpenTerminal<CR>
" noremap <leader>T :OpenTerminal<CR>
nnoremap <leader>T <Cmd>call jobstart(['thunar', expand('%:p')], {'detach': v:true})<CR>
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
nnoremap <leader>gg :call jobstart(['chromium', 'https://www.google.com/search?q=' . expand('<cword>')], {'detach': v:true})<CR>
" }}} Git and external tools
" {{{ Search navigation and YCM
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
nnoremap <leader>2 :YcmCompleter RefactorRename <C-r><C-w>
nnoremap <BS> :YcmCompleter GoToReferences<CR>
nnoremap <leader>w :YcmCompleter <tab>
" nnoremap <leader>w :YcmCompleter GetHover
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
" }}} Search navigation and YCM
" {{{ Plugin mappings
nnoremap <leader>X :YcmRestartServer<CR>
map <C-p> :FZF<CR>
map <Leader>a :Tagbar<CR>
noremap <leader>qq :call asyncrun#quickfix_toggle(8)<CR>
map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
nmap gf gF
" }}} Plugin mappings
" {{{ Mouse and grammar
" " move-lines XXX: I never used this
" nnoremap <A-j> :m .+1<CR>==
" nnoremap <A-k> :m .-2<CR>==
" inoremap <A-j> <Esc>:m .+1<CR>==gi
" inoremap <A-k> <Esc>:m .-2<CR>==gi
" vnoremap <A-j> :m '>+1<CR>gv=gv
" vnoremap <A-k> :m '<-2<CR>gv=gv

" append to l-register TODO
" vnoremap <leader>cl "Ayy

nnoremap <silent> <RightMouse> :call ClipboardPasteAsNewline()<CR>
inoremap <silent> <RightMouse> <C-o>:call ClipboardPasteInline()<CR>

vnoremap <silent> <RightMouse> "+y

nmap <leader>gr <Plug>(grammarous-open-info-window)
nmap <leader>grn <Plug>(grammarous-move-to-next-error)
nmap <leader>grp <Plug>(grammarous-move-to-previous-error)
" }}} Mouse and grammar
" }}} 🔑 Mappings
" {{{ 📄 Filetypes and autocommands
augroup user_filetypes
autocmd!
" {{{ Detection and general settings
" automatically hightlight the agt-query when reading agt results
autocmd BufRead /tmp/agt let @/ = readfile("/tmp/agt-query")[0] | call feedkeys("/\<CR>")

autocmd BufRead,BufNewFile tsconfig.json setlocal filetype=json5 syntax=json5

" BASH
autocmd BufNewFile   *.sh 0r ~/.vim/templates/sh
autocmd BufWritePre  *.sh call s:AddExecutablebitPre()
autocmd BufWritePost *.sh call s:AddExecutablebitPost()

autocmd FileType sh setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

autocmd FileType mail setlocal textwidth=71

" detect filetype sh
function! DetectShFiletype() abort
    let l:first_line = getline(1)
    if l:first_line =~# '^#!.*\<bash\>'
        setlocal filetype=bash
    elseif l:first_line =~# '^#!.*\<\%(sh\|dash\|zsh\)\>'
        setlocal filetype=sh
    endif
endfunction
autocmd BufReadPost,BufNewFile * call DetectShFiletype()

" detect filetype ansible
function! DetectAnsibleFiletype() abort
    if getline('$') ==# '# code: language=ansible'
        setlocal filetype=yaml.ansible
    endif
endfunction
autocmd BufReadPost,BufNewFile *.yml call DetectAnsibleFiletype()
" au BufRead,BufNewFile *.ansible.yml set filetype=ansible
" au FileType ansible setlocal commentstring=#\ %s

au BufRead,BufNewFile project.config set filetype=dosini

" systemd
autocmd BufRead,BufNewFile *.service,*.timer set filetype=systemd
" }}} Detection and general settings
" {{{ Web and data languages
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
autocmd FileType php setlocal textwidth=80 " for multi-line comments
" }}} Web and data languages
" {{{ Systems languages
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
autocmd FileType go nnoremap <buffer> <F2> :YcmCompleter RefactorRename <C-r><C-w>

" NIM
autocmd FileType nim nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR>
autocmd FileType nim nnoremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>
" }}} Systems languages
" {{{ Markup and configuration
" ELIXIR
" autocmd FileType elixir nnoremap <leader>r :w!<CR> :!elixir %<CR>

" PERL
" autocmd FileType perl nnoremap <leader>r :w!<CR> :!perl %<CR>

" PG/SQL
autocmd FileType sql nnoremap <silent> <buffer> <leader>c :!pgsanity %:p<CR>

" Git commits
autocmd FileType gitcommit setlocal textwidth=72

" JSON5
autocmd FileType json5 setlocal commentstring=//\ %s

" YAML
autocmd FileType yaml,yaml.ansible setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml,yaml.ansible setlocal indentkeys-=0# " stop comments from increasing indent
autocmd FileType yaml,yaml.ansible setlocal indentexpr= equalprg=cat

" MARKDOWN
autocmd FileType markdown setlocal list
autocmd FileType markdown nnoremap <silent> <buffer> <leader>r :LivedownPreview<CR>

" reSructured text
autocmd FileType rst nnoremap <silent> <buffer> <leader>r :silent !rstpreview % <CR>

" CMAKE
autocmd FileType cmake setlocal commentstring=#\ %s

" InnoSetup
autocmd FileType iss setlocal filetype=pascal
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

" Custom filetype detection and terminal-local mappings.
autocmd BufRead,BufNewFile *.thrift setlocal filetype=thrift
autocmd BufRead,BufNewFile *.ush,*.usher setlocal filetype=starlark
autocmd BufRead,BufNewFile *.gd setlocal filetype=gdscript
autocmd FileType gdscript setlocal list
autocmd TermOpen * nnoremap <buffer><nowait><silent> G :<C-u>call search('\S\_s*\%$')<CR>
autocmd TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>
autocmd FileType fzf tunmap <buffer> <Esc>
autocmd BufReadPost,BufFilePost,StdinReadPost * call s:AttemptToCdToGitDir()
" }}} Markup and configuration
augroup END
" {{{ Formatting and testing mappings
" <leader>j autoformatting/testing
augroup user_format_mappings
autocmd!
for entry in [
      \ ['Jenkinsfile'                ,  'autoformat-groovy'],
      \ ['bash,sh'                    ,  'autoformat-sh'],
      \ ['c'                          ,  'autoformat-c'],
      \ ['cpp'                        ,  'autoformat-c'],
      \ ['css'                        ,  'autoformat-css'],
      \ ['go'                         ,  'autoformat-go'],
      \ ['groovy'                     ,  'autoformat-groovy'],
      \ ['hcl'                        ,  'autoformat-hcl'],
      \ ['html'                       ,  'autoformat-html'],
      \ ['javascript'                 ,  'autoformat-js'],
      \ ['json'                       ,  'autoformat-json'],
      \ ['kotlin'                     ,  'autoformat-kotlin'],
      \ ['lua'                        ,  'autoformat-lua'],
      \ ['nix'                        ,  'nixpkgs-fmt'],
      \ ['python'                     ,  'autoformat-python'],
      \ ['star'                       ,  'autoformat-star'],
      \ ['starlark.python'            ,  'autoformat-star'],
      \ ['toml'                       ,  'autoformat-toml'],
      \ ['typescript,typescriptreact' ,  'autoformat-ts'],
      \ ['xml'                        ,  'autoformat-xml'],
      \ ['yaml,yaml.ansible'          ,  'autoformat-yml'],
      \ ]
  execute 'autocmd FileType ' . entry[0] .
        \ ' nnoremap <buffer> <leader>j :silent! execute ''!' . entry[1] . ' '' . shellescape(expand(''%''))<CR>'
endfor
autocmd FileType yaml nnoremap <buffer> <leader>k :!actionlint %<CR>
augroup END
" }}} Formatting and testing mappings
" {{{ Quickfix behavior
augroup user_quickfix
    autocmd!
    " override :YcmComplete GoTo for QF
    au FileType qf nmap <buffer> <CR> <CR>
augroup END
" }}} Quickfix behavior
" {{{ Additional filetype detection
augroup user_additional_filetypes
    autocmd!
    autocmd BufRead,BufNewFile *.jsonl setlocal filetype=plain
    autocmd BufRead,BufNewFile *.containerfile,*.Containerfile setlocal filetype=dockerfile
    autocmd BufRead,BufNewFile *.cfg.j2 setlocal filetype=cfg.jinja2
    autocmd BufRead,BufNewFile *.html.j2 setlocal filetype=html.jinja2
    autocmd BufRead,BufNewFile *.json.j2 setlocal filetype=jinja2
    autocmd BufRead,BufNewFile *.service.j2 setlocal filetype=systemd.jinja2
    autocmd BufRead,BufNewFile *.xml.j2 setlocal filetype=xml.jinja2
    autocmd BufRead,BufNewFile *.yml.j2 setlocal filetype=ansible
    autocmd BufRead,BufNewFile PKGBUILD setlocal filetype=sh
    autocmd FileType jinja setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType starlark setlocal filetype=starlark.python
    autocmd BufRead,BufNewFile * if empty(&filetype) | setlocal filetype=txt | endif
augroup END
" }}} Additional filetype detection
" }}} 📄 Filetypes and autocommands
" {{{ 🎨 Highlights
highlight DiffChange cterm=none ctermfg=16 ctermbg=18 gui=none guifg=bg guibg=Red
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
highlight NonText ctermfg=19
highlight Visual ctermfg=none ctermbg=239
highlight MatchParen cterm=none ctermfg=none ctermbg=245
highlight WinSeparator ctermfg=19 ctermbg=18
syntax region cPragma start="^\s*#pragma\s\+region\>" end="^\s*#pragma\s\+endregion\>" transparent fold
" }}} 🎨 Highlights
" {{{ 🚀 Post-plugin and Neovim setup
" {{{ Helm syntax
function HelmSyntax() abort
    setlocal filetype=yaml
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
" {{{ Split visual selection
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
" }}}
" {{{ Pop buffer into a new Vim instance
" Resolve realpath of current buffer, echo via system(), then close buffer
function! EchoRealpathCloseBuf() abort
    let l:path = expand('%:p')
    if empty(l:path)
        echoerr 'Current buffer has no file path.'
        return
    endif

    let l:realpath = fnamemodify(simplify(resolve(l:path)), ':p')
    call jobstart(['termpopup', '-ft', '--', 'vim', l:realpath], {'detach': v:true})

    " No bang: preserve the current buffer if it contains unsaved changes.
    bdelete
endfunction

" <Plug> mapping for flexibility
nnoremap <silent> <Plug>(EchoRealpathCloseBuf) :call EchoRealpathCloseBuf()<CR>

" nmap <silent> <leader>t <Plug>(EchoRealpathCloseBuf)
unmap <leader>te
unmap <leader>tm
unmap <leader>tc
unmap <leader>to
unmap <leader>tn
" }}}
" {{{ Split, jump, and sync
" Split, jump to nearest //! comment above, and sync horizontal scrolling
function! s:SplitJumpAndSyncHor() abort
  " 1) Ensure nowrap is set (so horizontal scroll actually happens)
  if &l:wrap
    setlocal nowrap
  endif

  " 2) Split the window (horizontal split of the current buffer)
  split

  " 3) Move to the above window
  wincmd k

  " 4) From the cursor line upward, find a line starting with optional indent then //! ...
  "    If found, the cursor lands there; if not, cursor stays where it was.
  call search('^\s*///', 'bcW')

  " 5) Sync horizontal scrolling between the two split windows
  "    (Use only horizontal binding; no vertical coupling.)
  "    Set on the current (top) window:
  setlocal scrollbind
  set scrollopt=hor

  "    Set on the other (bottom) window:
  wincmd j
  setlocal scrollbind
  set scrollopt=hor

  "    Return to the above window (where we positioned on the //! line)
  wincmd k
endfunction

" Map to <leader>V in normal mode
nnoremap <silent> <leader>V :call <SID>SplitJumpAndSyncHor()<CR>
" }}}
lua << LUA_INIT
-- {{{ Clipboard helpers
function ExchangeBufferWithClipboard()
  local buf_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local buf_text = table.concat(buf_content, "\n")

  -- Get clipboard content and normalize it
  local clipboard_lines = vim.split(vim.fn.getreg('+'), "\n")
  if clipboard_lines[#clipboard_lines] == "" then
    table.remove(clipboard_lines, #clipboard_lines)
  end
  local clipboard = table.concat(clipboard_lines, "\n")

  local msg = ""
  if buf_text == clipboard then
    msg = "Buffer was identical to clipboard."
  else
    -- Replace buffer with normalized clipboard content
    vim.api.nvim_buf_set_lines(0, 0, -1, false, clipboard_lines)
    msg = "Buffer was replaced with clipboard content."
  end

  vim.cmd('write')
  vim.api.nvim_echo({{msg, "None"}}, false, {})
end

function InsertClipboardAsCode(trim_last_line)
  -- Get clipboard contents as a list of lines
  local clipboard = vim.fn.getreg('+', 1, true)

  -- Optionally trim the last line if empty
  if trim_last_line and #clipboard > 0 and clipboard[#clipboard]:match('^%s*$') then
    table.remove(clipboard, #clipboard)
  end

  -- Add code block lines
  table.insert(clipboard, 1, '```')
  table.insert(clipboard, '```')

  -- Get current line number (0-based)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  -- Delete the current line
  vim.api.nvim_buf_set_lines(0, row-1, row, false, {})
  -- Insert at the position of the deleted line
  vim.api.nvim_buf_set_lines(0, row-1, row-1, false, clipboard)
end
-- }}} CLIPBOARD HELPERS
-- {{{ Tree-sitter
require("nvim-treesitter").setup({})

local treesitter_skip = { bash = true }
local treesitter_max_bytes = 2 * 1024 * 1024

local function start_treesitter(buf)
    local ft = vim.bo[buf].filetype
    if ft == "" or treesitter_skip[ft] or vim.bo[buf].buftype ~= "" then
        return
    end

    local name = vim.api.nvim_buf_get_name(buf)
    local stat = name ~= "" and vim.uv.fs_stat(name) or nil
    if stat and stat.size > treesitter_max_bytes then
        return
    end

    pcall(vim.treesitter.start, buf)
end

local treesitter_group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = treesitter_group,
    callback = function(args)
        start_treesitter(args.buf)
    end,
})

-- Filetype detection for the startup buffer has already happened by the time
-- this setup runs, so the FileType autocmd above cannot initialize it.
start_treesitter(vim.api.nvim_get_current_buf())
-- }}} TREESITTER
-- {{{ Window title
vim.opt.title = true

-- Prefix the title with an emoji, then show filename (+ modifiers)
-- %t  = tail of file name
-- %M  = [+] if modified
-- %R  = [RO] if readonly
-- %H  = [help] for help buffers
-- vim.opt.titlestring = "✍%t%M%R%H"
vim.opt.titlestring = "🔨 %t%M%R%H"
-- }}} AUTO TITLE
-- {{{ JSON path
local ts = vim.treesitter
local json_path_cache = {}

local function ts_node_text(node, bufnr)
    if not node then
        return ""
    end
    return ts.get_node_text(node, bufnr)
end

function _G.JsonPath()
    local ft = vim.bo.filetype
    if ft ~= "json" and ft ~= "jsonc" then
        return ""
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]
    local changedtick = vim.b[bufnr].changedtick
    local cached = json_path_cache[bufnr]
    if cached
        and cached.changedtick == changedtick
        and cached.row == row
        and cached.col == col
    then
        return cached.value
    end

    local value = ""
    local ok, parser = pcall(ts.get_parser, bufnr)
    if ok and parser then
        local tree = parser:parse()[1]
        local node = tree and tree:root():named_descendant_for_range(row, col, row, col)
        local parts = {}

        while node do
            if node:type() == "pair" then
                local key_node = node:field("key")[1]
                if key_node then
                    local key = ts_node_text(key_node, bufnr):gsub('^"(.*)"$', "%1")
                    table.insert(parts, 1, key)
                end
            end
            node = node:parent()
        end

        if #parts > 0 then
            value = "." .. table.concat(parts, ".")
        end
    end

    json_path_cache[bufnr] = {
        changedtick = changedtick,
        row = row,
        col = col,
        value = value,
    }
    return value
end

vim.g["airline_section_x"] = "%{v:lua.JsonPath()}"
-- }}} JSON_PATH
--[[ {{{ CtrlSF
vim.keymap.set('n', '<C-f>', function()
  -- Get word under cursor
  local word = vim.fn.expand('<cword>')
  if word == nil or word == '' then
    return
  end

  -- Run :CtrlSF <word>
  vim.cmd('CtrlSF ' .. vim.fn.shellescape(word))
end, { noremap = true, silent = true })
CTRLSEARCHF }}} ]]
LUA_INIT

nnoremap <leader>ss :lua ExchangeBufferWithClipboard()<CR>
nnoremap <leader>sa :lua InsertClipboardAsCode(true)<CR>
" }}} 🚀 Post-plugin and Neovim setup
