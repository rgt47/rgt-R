function! SelectChunk()
	:execute "normal! ?```{\<cr>jV/```\<cr>k"
endfunction
function! MoveNextChunk()
:execute "normal! /```{\<CR>j"
:noh
endfunction

function! MovePrevChunk()
:execute "normal! 2?```{\<CR>j"
:noh
endfunction

function! Raction(action)
:let @c = expand("<cword>")
:let @d=a:action . "(".@c.")\n"
:call term_sendkeys(term_list()[0], @d)
endfunction

function! SubmitLine()
:let @c = getline(".") . "\n"
:call term_sendkeys(term_list()[0], @c)
endfunction
"
function! GetVisualSelection(mode)
" call with visualmode() as the argument
let [line_start, column_start] = getpos("'<")[1:2]
let [line_end, column_end]     = getpos("'>")[1:2]
let lines = getline(line_start, line_end)
if a:mode ==# 'v'
" Must trim the end before the start, the beginning will shift left.
let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
let lines[0] = lines[0][column_start - 1:]
elseif  a:mode ==# 'V'
else
return ''
endif
return join(lines, "\n")
endfunction


function! SubmitSelTest()
y
:let @c=@" . "\n"
:call term_sendkeys(term_list()[0], @c)
endfunction

function! Submit1()
:let y = "source('source_visual',echo=T)" . "\n"
:let ty = type(y)
echom "type of y is " . ty
echom y
:call term_sendkeys(term_list()[0], y)
endfunction

function! Sel1()
:let @c= GetVisualSelection(visualmode()) . "\n"
:call writefile(getreg('c', 1, 1), "source_visual")
endfunction

function! Brk()
:call term_sendkeys(term_list()[0], "\<c-c>")
endfunction

augroup r_rmd_qmd
    autocmd!
autocmd FileType r,rmd,qmd nnoremap <silent> <CR> :call SubmitLine()<CR><CR>
autocmd FileType r,rmd,qmd vnoremap <silent> <CR> :call Sel1() \| :call Submit1()<CR><CR>
" autocmd FileType r,rmd,qmd noremap <silent> <S-CR> :call Submit1()<CR><CR>
" autocmd FileType r,rmd,qmd vnoremap <silent> <S-CR> :call SubmitSelTest()<CR><CR>

autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>c :call Brk()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>l :call SelectChunk()<CR> \| :call Sel1() \| :call Submit1()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>; :call SelectChunk()<CR> \| :call Sel1() \| :call Submit1()<CR> \| /```{<CR>j
autocmd FileType r,rmd,qmd nnoremap <localleader>k :call MovePrevChunk()<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>j :call MoveNextChunk()<CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>r :vert term R  --no-save<CR><c-w>:wincmd p<CR>
autocmd FileType r,rmd,qmd nnoremap ZT :!R --quiet -e 'render("<C-r>%", output_format="pdf_document")'<CR>
autocmd FileType r,rmd,qmd nnoremap ZY :!R --quiet -e 'quarto_render("<C-r>%", output_format="pdf")'<CR>
autocmd FileType r,rmd,qmd tnoremap ZD quarto::quarto_render(output_format = "pdf")<CR>
autocmd FileType r,rmd,qmd tnoremap ZO source("<C-W>"%")
autocmd FileType r,rmd,qmd tnoremap ZR render("<C-W>"%")<CR>
autocmd FileType r,rmd,qmd tnoremap ZS style_dir()<CR>
autocmd FileType r,rmd,qmd tnoremap ZQ q('no')<C-\><C-n>:q!<CR>
autocmd FileType r,rmd,qmd tnoremap ZZ q('no')<C-\><C-n>:q!<CR>
autocmd FileType r,rmd,qmd tnoremap lf ls()<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>d :call Raction("dim")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>h :call Raction("head")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>s :call Raction("str")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>p :call Raction("print")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>n :call Raction("names")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>f :call Raction("length")<CR>
augroup END


autocmd FileType r,rmd,qmd vnoremap <silent> <localleader>z :w! temp.R<CR> \|
\ :let @y = "sink('temp.txt'); source('temp.R',echo=T); sink()" . "\n"<CR>
\ :call term_sendkeys(term_list()[0], @y)<CR> \|
\ :r !cat temp.txt \| sed 's/^/\# /g'<CR>
