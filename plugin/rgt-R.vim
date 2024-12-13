" Select a markdown chunk by searching for backticks and entering visual mode
function! SelectChunk()
    if search('```{', 'bW')
        normal! jV
        if !search('```', 'W')
            echo "No matching closing backticks found"
        endif
    else
        echo "No markdown chunks found above"
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
