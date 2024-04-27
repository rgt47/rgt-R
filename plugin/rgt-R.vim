nnoremap <silent> <localleader><CR>  :let @c = getline(".") . "\n" \|
			\ :call term_sendkeys(term_list()[0], @c)<CR><CR>
vnoremap  <silent> <localleader>v y \| :let @c=@" . "\n" <CR> \|
	\ :call term_sendkeys(term_list()[0], @c)<CR>
vmap <silent> <localleader><CR> <space>v}
" space-j to move to next chunk
nnoremap <localleader>j /```{<CR>j
" space-k to move to prev chunk
nnoremap <localleader>k 2?```{<CR>j
" C-CR to highlight and run current chunk
nmap <localleader>' ?```{<CR>jV/```<CR>k<space>v/```{<CR>j/zqzq<CR>
" nmap <localleader>l ?```{<CR>jV/```<CR>k<C-v>/```{<CR>j/zqzq<CR>
"
" space-;' to highlight from cursor to end of chunk
nnoremap <localleader>; V/```<CR>kC-v>/```{<CR>j/zqzq<CR>
" space-r to start R
nnoremap <silent> <localleader>r :vert term R <CR><c-w>:wincmd p<CR>

nnoremap ZT :!R -e 'render("<C-r>%", output_format="pdf_document")'<CR>

tnoremap ZD quarto::quarto_render(output_format = "pdf")<CR>
tnoremap ZO source("<C-W>"%")
tnoremap ZR render("<C-W>"%")<CR>
tnoremap ZS style_dir()<CR>
tnoremap ZQ q('no')<C-\><C-n>:q!<CR>
tnoremap ZZ q('no')<C-\><C-n>:q!<CR>
" quick list of files for debug: lf
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
" nnoremap <silent>  <localleader>d :let @c=expand("<cword>") \|
" \ :let @d="dim(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
" nnoremap <silent>  <localleader>h :let @c=expand("<cword>") \|
" \ :let @d="head(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
" nnoremap <silent>  <localleader>s :let @c=expand("<cword>") \|
" \ :let @d="str(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
" nnoremap <silent>  <localleader>p :let @c=expand("<cword>") \|
" \ :let @d="print(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
" nnoremap <silent>  <localleader>n :let @c=expand("<cword>") \|
" \ :let @d="names(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
" nnoremap <silent>  <localleader>l :let @c=expand("<cword>") \|
" \ :let @d="length(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
