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


function! Submit()
:let y = "source('source_visual',echo=T)" . "\n"
:call term_sendkeys(term_list()[0], y)
" :call delete('source_visual')
endfunction

function! Sel()
:let @c= GetVisualSelection(visualmode()) . "\n"
:call writefile(getreg('c', 1, 1), "source_visual")
endfunction

function! Brk()
:call term_sendkeys(term_list()[0], "\<c-c>")
endfunction

function! BrowserBrk()
:call term_sendkeys(term_list()[0], "Q\n")
endfunction

function! SubmitEmbed()
:let y = "sink('temp.txt'); source('source_visual',echo=T); sink()" . "\n"
:call term_sendkeys(term_list()[0], y)
" :call delete('source_visual')
endfunction

function! Rd()
!sed 's/^/\# /g' temp.txt > temp_commented.txt
:r !cat temp_commented.txt 
endfunction

augroup r_rmd_qmd
    autocmd!
autocmd FileType r,rmd,qmd nnoremap <silent> <CR> :call SubmitLine()<CR><CR>
autocmd FileType r,rmd,qmd vnoremap <silent> <CR> :call Sel() \| 
			\ :call Submit()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>c 
			\ :call Brk()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>q 
			\ :call BrowserBrk()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>l 
	\ :call SelectChunk()<CR> \| :call Sel() \| :call Submit()<CR><CR>
" send chunk to R and move to next chunk and center vertically 
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>; 
\ :call SelectChunk()<CR> \| :call Sel() \| :call Submit()<CR> \| /```{<CR>jzz
autocmd FileType r,rmd,qmd nnoremap <localleader>k :call MovePrevChunk()<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>j :call MoveNextChunk()<CR>
autocmd FileType r,rmd,qmd nnoremap <silent> <localleader>r 
			\ :vert term R  --no-save<CR><c-w>:wincmd p<CR>
autocmd FileType r,rmd,qmd nnoremap ZT :!R --quiet -e 
			\ 'render("<C-r>%", output_format="pdf_document")'<CR>
autocmd FileType r,rmd,qmd nnoremap ZY :!R --quiet -e 
			\ 'quarto_render("<C-r>%", output_format="pdf")'<CR>
autocmd FileType r,rmd,qmd tnoremap ZD 
			\ quarto::quarto_render(output_format = "pdf")<CR>
autocmd FileType r,rmd,qmd tnoremap ZO source("<C-W>"%")
autocmd FileType r,rmd,qmd tnoremap ZR render("<C-W>"%")<CR>
autocmd FileType r,rmd,qmd tnoremap ZQ q('no')<C-\><C-n>:q!<CR>
autocmd FileType r,rmd,qmd tnoremap ZZ q('no')<C-\><C-n>:q!<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>d :call Raction("dim")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>h :call Raction("head")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>s :call Raction("str")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>p :call Raction("print")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>n :call Raction("names")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>f :call Raction("length")<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>g :call Raction("glimpse")<CR>
autocmd FileType r,rmd,qmd inoremap <c-l> 
			\ <esc>A \|><CR><C-o>0<space><space>
autocmd FileType r,rmd,qmd vnoremap <silent> <localleader>z 
		\ :call Sel() \| :call SubmitEmbed() \| :call Rd()<CR><CR>
augroup END


