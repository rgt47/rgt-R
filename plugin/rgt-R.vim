function! SubmitLine()
:let @c = getline(".") . "\n"
:call term_sendkeys(term_list()[0], @c)
endfunction

function! SubmitSel()
y
:let @c=@" . "\n"
:call term_sendkeys(term_list()[0], @c)
endfunction

nnoremap <silent> <CR> :call SubmitLine()<CR><CR>
vnoremap <silent> <CR> :call SubmitSel()<CR><CR>

function! SelectChunk()
	:execute "normal! ?```{\<cr>jV/```\<cr>k"
endfunction

function! MoveNextChunk()
:execute "normal! /```{\<CR>j"
:noh
endfunction

noremap <silent> <S-CR> :call SelectChunk()<CR> \| :call SubmitSel()<CR>
nnoremap <silent> <C-CR> :call MoveNextChunk()<CR>

nnoremap <localleader>k 2?```{<CR>j
nnoremap <localleader>j /```{<CR>j

nnoremap <silent> <localleader>r :vert term R <CR><c-w>:wincmd p<CR>
nnoremap ZT :!R -e 'render("<C-r>%", output_format="pdf_document")'<CR>

tnoremap ZD quarto::quarto_render(output_format = "pdf")<CR>
tnoremap ZO source("<C-W>"%")
tnoremap ZR render("<C-W>"%")<CR>
tnoremap ZS style_dir()<CR>
tnoremap ZQ q('no')<C-\><C-n>:q!<CR>
tnoremap ZZ q('no')<C-\><C-n>:q!<CR>
tnoremap lf ls()<CR>

function! Raction(action)
:let @c = expand("<cword>")
:let @d=a:action . "(".@c.")\n"
:call term_sendkeys(term_list()[0], @d)
endfunction

nnoremap <localleader>d :call Raction("dim")<CR>
nnoremap <localleader>h :call Raction("head")<CR>
nnoremap <localleader>s :call Raction("str")<CR>
nnoremap <localleader>p :call Raction("print")<CR>
nnoremap <localleader>n :call Raction("names")<CR>
nnoremap <localleader>l :call Raction("length")<CR>

vnoremap <silent> <localleader>z :w! temp.R<CR> \|
\ :let @y = "sink('temp.txt'); source('temp.R',echo=T); sink()" . "\n"<CR>
\ :call term_sendkeys(term_list()[0], @y)<CR> \|
\ :r !cat temp.txt \| sed 's/^/\# /g'<CR>
