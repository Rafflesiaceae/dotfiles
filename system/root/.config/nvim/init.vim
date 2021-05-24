set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

if filereadable("/etc/vimrc")
    source /etc/vimrc
endif

set ttimeoutlen=0

set nocompatible
filetype off

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

" finally disable ex mode
nnoremap Q <Nop>

" need no help bindings
nmap <F1> <nop>
imap <F1> <nop>

" auto BufEnter * let &titlestring = hostname() . "/" . expand("%:p")
set title titlestring=%t titlelen=70

set diffopt+=iwhite

set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
set iskeyword=@,48-57,_,192-255

highlight DiffChange cterm=none ctermfg=16 ctermbg=18 gui=none guifg=bg guibg=Red
autocmd FilterWritePre * if &diff | setlocal wrap< | endif


colorscheme base16-kokonai
let base16colorspace=256  " Access colors present in 256 colorspace
set background=dark

set t_kB=^[[Z " makes Shift+Tab work?!

let s:os = substitute(system('uname'), "\n", "", "")

" Configurations
" " {{{ Ack / G
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
" " }}}
" {{{ fzf
map <C-p> :FZF<CR>
" }}}
" {{{ neovim terminal
" G jumps to last outputted line instead of to the very bottom of the buffer, which in a terminal is always the complete height of the terminal emulator
au TermOpen * nno <buffer><nowait><silent> G :<c-u>call search('\S\_s*\%$')<cr>
" }}}

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

" <leader>v selects the just pasted text
nnoremap <leader>v V`]

" highlight on d-click
nnoremap <silent> <2-LeftMouse> :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:set hls<cr>

" goto on t-click
nnoremap <silent> <3-LeftMouse> :YcmCompleter GoTo<cr>

map <C-n> :NERDTreeToggle<CR>
nmap <S-Enter> O<Esc>

vnoremap // y/\V<C-R>"<CR>
nnoremap <leader>cs :noh<CR>

nnoremap <leader>sp :cd %:p:h<CR>
nnoremap <leader>ss :AsyncStop<CR>

nnoremap <leader>m :buffers<CR>:buffer<Space>

nnoremap <C-s> :w!<CR>
nnoremap <leader>w :w!<CR>
nnoremap <leader>W :w!<CR>:e!<CR>
nnoremap <leader>l :e!<CR>

" @TODO only in diffmode ( https://vi.stackexchange.com/a/2706 ?)
" nnoremap <silent> <leader>dp V:diffput<cr>
" nnoremap <silent> <leader>dg V:diffget<cr>

nnoremap <silent> <leader>vb :Gblame<cr>

nnoremap <silent> <leader>s :%s/\<<C-r><C-w>\>/

nnoremap <silent> <leader>cf :cd %:p:h<CR>

nnoremap <leader>r :Run<CR>
nmap <leader>o :let @*=expand("%:p")<CR>
map <C-q> :qa!<CR>
" map <C-c> :w<CR>

tnoremap <Esc> <C-\><C-n>
cnoremap <C-a> <Home>

nnoremap <leader>cy :%y+<CR>
vnoremap <leader>cy "+y<CR>
nnoremap <leader>cd :%d+<CR>
vnoremap <leader>cd "+d<CR>
nnoremap <leader>cp "+p<CR>
nnoremap <leader>cP "+P<CR>
nnoremap <leader>cw "+yiw<CR>

nnoremap <leader>m :buffers<CR>:buffer<Space>

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
nnoremap <silent> <CR> :YcmCompleter GoTo<CR>
nnoremap <silent> <BS> :YcmCompleter 
    
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

" {{{ Autocommands
" BASH
autocmd BufNewFile   *.sh 0r ~/.vim/templates/sh
autocmd BufWritePre  *.sh call s:AddExecutablebitPre()
autocmd BufWritePost *.sh call s:AddExecutablebitPost()

autocmd FileType sh setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

" JSON
autocmd FileType json setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

" XML
autocmd FileType xml setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

" Jenkinsfile
autocmd FileType Jenkinsfile setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

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
autocmd FileType typescript noremap <buffer> <leader>d :YcmCompleter FixIt 

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
autocmd FileType c   setlocal expandtab shiftwidth=3 tabstop=3 softtabstop=3
autocmd FileType cpp setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType c   nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR> 
autocmd FileType cpp nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR> 
autocmd FileType c   noremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>
autocmd FileType cpp noremap <silent> <buffer> <BS> :YcmCompleter GoToReferences<cr>

autocmd FileType c   noremap <silent> <buffer> <F1> :call CurtineIncSw()<CR>
autocmd FileType cpp noremap <silent> <buffer> <F1> :call CurtineIncSw()<CR>
" autocmd FileType cpp nnoremap <leader>r :w!<CR> :!runcpp %<CR>
"
autocmd FileType cpp setlocal commentstring=//\ %s
autocmd FileType c   setlocal commentstring=//\ %s

" OBJC
autocmd FileType objc setlocal commentstring=//\ %s

" GO
" autocmd FileType go nnoremap <leader>r :w!<CR> :!go run %<CR>
autocmd FileType go nnoremap <silent> <buffer> <cr> :YcmCompleter GoTo<CR>
autocmd FileType go nnoremap <silent> <buffer> <leader>gi :GoImports<CR>
autocmd FileType go nnoremap <silent> <buffer> <leader>gt :GoTest<CR>
" autocmd FileType go nnoremap <silent> <buffer> <leader>r :GoImports <CR> \| :belowright 20split \| terminal go run %<CR>
" autocmd FileType go nnoremap <silent> <buffer> <leader>r :GoImports<CR>:Run<CR>
" https://github.com/fatih/vim-go/issues/502#issuecomment-169083550
autocmd BufWritePost *.go normal! zv

" ELIXIR
" autocmd FileType elixir nnoremap <leader>r :w!<CR> :!elixir %<CR>

" PERL
" autocmd FileType perl nnoremap <leader>r :w!<CR> :!perl %<CR>

" PG/SQL
autocmd FileType sql nnoremap <silent> <buffer> <leader>c :!pgsanity %:p<CR>

autocmd FileType gitcommit set tw=72

" JSON
autocmd BufRead,BufNewFile tsconfig.json set filetype=json5

" JSON5
autocmd FileType json5 setlocal commentstring=//\ %s

" YAML
autocmd FileType yaml setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

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

" }}}

" {{{ Custom Functions
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

" function! GoogleWordUnderCursor()
"     let wordUnderCursor = expand("<cword>")
"     call system("chromium \"http://www.google.com/search?q=".wordUnderCursor."\"")
"     " echo wordUnderCursor
" endfunction
" nmap <leader>gg :call GoogleWordUnderCursor()<CR>
" nmap <leader>gg :system("chromium \"http://www.google.com/search?q=".wordUnderCursor.<cword>")<CR>

"" toggle ,/; characters at the end of a line
function! ToggleEolCharacter(char)
    " TODO: replace last char if its one of the ones we use with the one we want, e.g. ,=>; if we <leader>;
    let line = getline(".")
    if line[len(line)-1] == a:char
       call setline( ".", strpart(line, 0, len(line)-1) )
    else
       call setline( ".", line . a:char )
    endif
endfunction
nmap <leader>, :call ToggleEolCharacter(",")<CR>
nmap <leader>. :call ToggleEolCharacter(";")<CR>

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
