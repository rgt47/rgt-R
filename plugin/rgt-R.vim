" Select a markdown chunk by searching for backticks and entering visual mode
function! SelectChunk()
    if search('```{', 'bW')
        normal! jV
        if !search('```', 'W')
            echo "No matching closing backticks found"
        endif
    else
        echo "No rmarkdown chunks found above"
    endif
endfunction

" Move to the next markdown chunk
function! MoveNextChunk()
    if search('```{', 'W')
        normal! j
    else
        echo "No further chunks found"
    endif
    noh
endfunction

" Move to the previous markdown chunk
function! MovePrevChunk()
    if search('```{', 'bW')
        normal! j
    else
        echo "No previous chunks found"
    endif
    noh
endfunction

" Perform an action with the current word in the terminal
function! Raction(action)
    let current_word = expand("<cword>")
    let command = a:action . "(" . current_word . ")\n"
    call term_sendkeys(term_list()[0], command)
endfunction

" Submit the current line to the terminal
function! SubmitLine()
    let current_line = getline(".") . "\n"
    call term_sendkeys(term_list()[0], current_line)
endfunction

" Get the visually selected text
function! GetVisualSelection(mode)
    " Call with visualmode() as the argument
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)

    if a:mode ==# 'v'
        " Trim the start and end for character-wise selection
        let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
    elseif a:mode ==# 'V'
        " No modification needed for line-wise selection
    else
        echo "Unsupported visual mode"
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
" Key mappings
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>sc :call SelectChunk()<CR> " Select a markdown chunk
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>mn :call MoveNextChunk()<CR> " Move to the next markdown chunk
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>mp :call MovePrevChunk()<CR> " Move to the previous markdown chunk
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>sl :call SubmitLine()<CR> " Submit the current line to the terminal

" Raction mappings
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>rd :call Raction("dim")<CR> " Perform dim() on the word under the cursor
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>rh :call Raction("head")<CR> " Perform head() on the word under the cursor
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>rn :call Raction("names")<CR> " Perform names() on the word under the cursor
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>rp :call Raction("print")<CR> " Perform print() on the word under the cursor
autocmd FileType r,rmd,qmd nnoremap <LocalLeader>rf :call Raction("length")<CR> " Perform length() on the word under the cursor

autocmd FileType r,rmd,qmd nnoremap <localleader>rs 
			\ :vert term R  --no-save<CR><c-w>:wincmd p<CR>
autocmd FileType r,rmd,qmd nnoremap <CR> :call SubmitLine()<CR><CR>
autocmd FileType r,rmd,qmd vnoremap <CR> :call Sel() \| 
			\ :call Submit()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>c 
			\ :call Brk()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>q 
			\ :call BrowserBrk()<CR><CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>l 
	\ :call SelectChunk()<CR> \| :call Sel() \| :call Submit()<CR><CR>
" send chunk to R and move to next chunk and center vertically 
autocmd FileType r,rmd,qmd nnoremap <localleader>; 
\ :call SelectChunk()<CR> \| :call Sel() \| :call Submit()<CR> \| /```{<CR>jzz
autocmd FileType r,rmd,qmd nnoremap <localleader>k :call MovePrevChunk()<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>j :call MoveNextChunk()<CR>
autocmd FileType r,rmd,qmd nnoremap <localleader>r 
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
autocmd FileType r,rmd,qmd inoremap <c-l>  <esc>A \|><CR><C-o>0<space><space>
autocmd FileType r,rmd,qmd nnoremap <c-l> A \|><CR>0<space><space>
autocmd FileType r,rmd,qmd vnoremap <localleader>z  :call Sel() \| :call SubmitEmbed() \| :call Rd()<CR><CR>
