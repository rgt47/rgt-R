nnoremap <silent> <localleader><CR>  :let @c = getline(".") . "\n" \|
			\ :call term_sendkeys(term_list()[0], @c)<CR><CR>
vnoremap  <silent> <localleader>v y \| :let @c=@" . "\n" <CR> \|
	\ :call term_sendkeys(term_list()[0], @c)<CR>
vmap <silent> <localleader><CR> <space>v}
vnoremap <silent> <localleader>z :w! temp.R<CR> \| 
\ :let @y = "sink('temp.txt'); source('temp.R',echo=T); sink()" . "\n"<CR>
\ :call term_sendkeys(term_list()[0], @y)<CR> \|
\ :r !cat temp.txt \| sed 's/^/\# /g'<CR>
" space-j to move to next chunk
nnoremap <localleader>j /```{<CR>j
" space-l to highlight and run current chunk
nmap <localleader>l ?```{<CR>jV/```<CR>k<C-v>/```{<CR>j/zqzq<CR>

" space-k to move to prev chunk
nnoremap <localleader>k 2?```{<CR>j
" space-;' to highlight from cursor to end of chunk
nnoremap <localleader>h V/```<CR>k
" nnoremap <C-l> V3j
nnoremap <silent> <localleader>r :vert term R <CR><c-w>:wincmd p<CR>
" nnoremap <silent>  <localleader>d :let @c=expand("<cword>") \|
" \ :let @d="dim(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
" nnoremap <silent>  <localleader>h :let @c=expand("<cword>") \|
" \ :let @d="head(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <silent>  <localleader>s :let @c=expand("<cword>") \|
\ :let @d="str(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <silent>  <localleader>p :let @c=expand("<cword>") \|
\ :let @d="print(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <silent>  <localleader>n :let @c=expand("<cword>") \|
\ :let @d="names(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>
nnoremap <silent>  <localleader>l :let @c=expand("<cword>") \|
\ :let @d="length(".@c.")"."\n"   \| :call term_sendkeys(term_list()[0], @d)<CR>

tnoremap ZD quarto::quarto_render(output_format = "pdf")<CR>
tnoremap ZO source("<C-W>"%")
tnoremap ZQ q('no')<C-\><C-n>:q!<CR>
tnoremap ZR render("<C-W>"%")<CR>
nnoremap ZT :!R -e 'render("<C-r>%", output_format="pdf_document")'<CR>
tnoremap ZS style_dir()<CR>
tnoremap ZZ q('no')<C-\><C-n>:q!<CR>
tnoremap lf ls()<CR> "list files

function! Raction(action)
:let @c = expand("<cword>")
:let @d=a:action . "(".@c.")\n"
:call term_sendkeys(term_list()[0], @d)
endfunction

nnoremap <localleader>d :call Raction("dim")<CR>
nnoremap <localleader>h :call Raction("head")<CR>
