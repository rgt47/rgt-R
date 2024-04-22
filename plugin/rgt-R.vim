nnoremap <silent> <C-CR> :let @c = getline(".") . "\n" \|
			\ :call term_sendkeys(term_list()[0], @c)<CR><CR>
vnoremap  <silent> <C-v> y \| :let @c=@" . "\n" <CR> \|  
	\ :call term_sendkeys(term_list()[0], @c)<CR> 
vmap <silent> <C-CR> <C-v>}
" vnoremap <C-CR> :w temp.R<CR> \| :let @x = "source('temp.R')" \|
" 		\ :call term_sendkeys(term_list()[0], @x)<CR> \| :+1<CR>}
vnoremap <F2> :w! temp.R<CR>
" nnoremap <F3> :let @x = "source('temp.R',echo=T)" . "\n"<CR>
" nnoremap <F4> :call term_sendkeys(term_list()[0], @x)<CR>
" nnoremap <F5> :r !R -q --no-echo -e 'options(echo=F); source("temp.R",ec=T)' \| 
" 		\ sed 's/^/\# /g'<CR>
nnoremap <F6> :let @y = "sink('temp.txt'); 
\ source('temp.R',echo=T); sink()" . "\n"<CR>
" nnoremap <F7> :call term_sendkeys(term_list()[0], @y)<CR>
" nnoremap <F8> :r !cat temp.txt \| sed 's/^/\# /g'<CR>
nnoremap <F7> :call term_sendkeys(term_list()[0], @y)<CR> \|
	\ :r !cat temp.txt \| sed 's/^/\# /g'<CR>


" control-j to move to next chunk
nnoremap <C-j> /```{<CR>j
" control-l to highlight and run current chunk
nmap <C-l> ?```{<CR>jV/```<CR>k<C-v>/```{<CR>j/zqzq<CR>

" control-k to move to prev chunk
nnoremap <C-k> 2?```{<CR>j
" control-;' to highlight from cursor to end of chunk
nnoremap <C-h> V/```<CR>k
" nnoremap <C-l> V3j




tnoremap ZD quarto::quarto_render(output_format = "pdf")<CR>
tnoremap ZO source("<C-W>"%")
tnoremap ZQ q('no')<C-\><C-n>:q!<CR>
tnoremap ZR render("<C-W>"%")<CR>
nnoremap ZT :!R -e 'render("<C-r>%", output_format="pdf_document")'<CR>
tnoremap ZS style_dir()<CR>
tnoremap ZX exit<CR>
tnoremap ZZ q('no')<C-\><C-n>:q!<CR>

nnoremap <localleader>r :vert term R <CR><c-w>:wincmd p<CR>

nnoremap <localleader>d :let @c=expand("<cword>") \| 
\ :let @d="dim(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <localleader>h :let @c=expand("<cword>") \| 
\ :let @d="head(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <localleader>s :let @c=expand("<cword>") \| 
\ :let @d="str(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <localleader>p :let @c=expand("<cword>") \| 
\ :let @d="print(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <localleader>n :let @c=expand("<cword>") \| 
\ :let @d="names(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <localleader>l :let @c=expand("<cword>") \| 
\ :let @d="length(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>

tnoremap lf ls()<CR> "list files

