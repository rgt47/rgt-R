" rgt-R.vim
" A Vim plugin for working with R and R Markdown files, sending code to an R terminal.

"------------------------------------------------------------------------------
" Utility Functions
"------------------------------------------------------------------------------

" Check if an R terminal is available
function! s:has_r_terminal() abort
    let terms = term_list()
    return !empty(terms)
endfunction

" Safely send keys to the R terminal, if available
function! s:send_to_r(cmd) abort
    if !s:has_r_terminal()
        echo "No R terminal available."
        return
    endif
    let terms = term_list()
    call term_sendkeys(terms[0], a:cmd)
endfunction

"------------------------------------------------------------------------------
" Core Functions
"------------------------------------------------------------------------------

function! GetVisualSelection(mode) abort
    let [line_start, col_start] = getpos("'<")[1:2]
    let [line_end, col_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)

    if a:mode ==# 'v'
        let lines[-1] = lines[-1][: col_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][col_start - 1:]
    elseif a:mode ==# 'V'
        " Line-wise selection, no trimming needed
    else
        echo "Unsupported visual mode"
        return ''
    endif

    return join(lines, "\n")
endfunction

" Select a markdown chunk by searching for backticks and entering visual mode
function! SelectChunk() abort
    " Search backwards for the opening of an R Markdown chunk
    if search('^```{', 'bW')
        " Move to the next line (start of the chunk content)
        normal! j

        " Start visual line mode
        normal! V

        " Search forwards for the closing backticks
        if search('^```$', 'W')
            " Move up one line to exclude the closing backticks
            normal! k
        else
            echo "No matching closing backticks found."
            normal! <Esc> " Exit visual mode if no match found
        endif
    else
        echo "No R Markdown chunks found above."
    endif
endfunction

" Move to the next markdown chunk
function! MoveNextChunk() abort
    if search('```{', 'W')
        normal! j
    else
        echo "No further chunks found."
    endif
    noh
endfunction

" Move to the previous markdown chunk
function! MovePrevChunk() abort
    " Search backwards for the previous chunk opening delimiter (``` with optional text)
    if search('^\s*```.*', 'bW')
        " Move the cursor to the next line (start of the chunk content)
        normal! j
    else
        echo "No previous chunk found."
    endif
    noh
endfunction

" Perform an action on the current word in the terminal
function! Raction(action) abort
    if !s:has_r_terminal()
        echo "No R terminal available."
        return
    endif
    let current_word = expand("<cword>")
    let command = a:action . "(" . current_word . ")\n"
    call s:send_to_r(command)
endfunction

" Submit the current line to the R terminal
function! SubmitLine() abort
    let current_line = getline(".") . "\n"
    call s:send_to_r(current_line)
endfunction

function! Submit() abort
    if !exists("g:source_file")
        echo "No source file available."
        return
    endif
    let cmd = "source('" . g:source_file . "', echo=T)\n"
    call s:send_to_r(cmd)
endfunction

function! SubmitEmbed() abort
    if !exists("g:source_file")
        echo "No source file available."
        return
    endif
    let cmd = "sink('temp.txt'); source('" . g:source_file . "',echo=T); sink()\n"
    call s:send_to_r(cmd)
endfunction

" Select and write visual selection to a temporary file
function! Sel() abort
    let visual_selection = GetVisualSelection(visualmode())
    if visual_selection == ''
        return
    endif
    let g:source_file = tempname()
    call writefile(split(visual_selection, "\n"), g:source_file)
endfunction

" Break the current R process
function! Brk() abort
    call s:send_to_r("\<c-c>")
endfunction

" Break the R debug browser
function! BrowserBrk() abort
    call s:send_to_r("Q\n")
endfunction

" Read the output back as commented lines
function! Rd() abort
    !sed 's/^/# /g' temp.txt > temp_commented.txt
    execute 'r !cat temp_commented.txt'
endfunction
"
function! CollectPreviousChunks() abort
    " Define the chunk delimiter as lines starting with ``` and optional text
    let l:chunk_delimiter = '^\s*```.*'

    " Get the current line number
    let l:current_line = line('.')

    " Initialize variables to collect lines
    let l:all_lines = []
    let l:start_line = 1

    " Loop through lines up to the current line
    for l:line in range(1, l:current_line)
        if match(getline(l:line), l:chunk_delimiter) != -1
            " When finding a delimiter, add lines from the previous chunk
            let l:all_lines += getline(l:start_line, l:line - 1)
            let l:start_line = l:line + 1
        endif
    endfor

    " Return the collected lines joined as a single string
    return join(l:all_lines, "\n")
endfunction
"------------------------------------------------------------------------------
" Mapping to Collect and Submit All Previous Chunks
"------------------------------------------------------------------------------

" Collect and submit all previous chunks to R
function! CollectAndSubmitPreviousChunks() abort
    " Collect all previous chunks
    let l:previous_chunks = CollectPreviousChunks()

    " Check if there is anything to submit
    if empty(l:previous_chunks)
        echo "No previous chunks to submit."
        return
    endif

    " Submit to R using the existing send_to_r function
    call s:send_to_r(l:previous_chunks . "\n")
    echo "Submitted all previous chunks to R."
endfunction

"------------------------------------------------------------------------------
" Check and Submit Functions
"------------------------------------------------------------------------------

" Called by normal mode <CR>: submit line if terminal available, else show message
function! s:CheckTerminalAndSubmitLineNormal() abort
    if s:has_r_terminal()
        call SubmitLine()
        " Move to the next line after submitting
        normal! j
    else
        echo "No R terminal available."
    endif
endfunction

" Called by visual mode <CR>: submit selection if terminal available, else show message
function! s:CheckTerminalAndSubmitVisual() abort
    if s:has_r_terminal()
        call Sel()
        call Submit()
    else
        echo "No R terminal available."
    endif
endfunction

"------------------------------------------------------------------------------
" Autocommands and Mappings
"------------------------------------------------------------------------------

augroup RMarkdownMappings
    autocmd!
    " Normal mode: Press <CR> to submit line if R terminal open, else show message
    autocmd FileType r,rmd,qmd nnoremap <buffer> <CR> :call <SID>CheckTerminalAndSubmitLineNormal()<CR>

    " Visual mode: Press <CR> to submit selection if R terminal open, else show message
    autocmd FileType r,rmd,qmd xnoremap <buffer> <CR> :<C-u>call <SID>CheckTerminalAndSubmitVisual()<CR>

    " Break the current R process
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>c :call Brk()<CR><CR>

    " Break the current R debug process
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>q :call BrowserBrk()<CR><CR>

    " Select a chunk and send it to R
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>l :call SelectChunk()<CR> \| :call Sel() \| :call Submit()<CR><CR>

    " Select a chunk, send it to R, move to next chunk, center vertically
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>; :call SelectChunk()<CR> \| :call Sel() \| :call Submit()<CR> \| /```{<CR>jzz:noh<CR>

    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>' :call CollectAndSubmitPreviousChunks()<CR>
    " Move to previous/next chunk
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>k :call MovePrevChunk()<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>j :call MoveNextChunk()<CR>

    " Open an R terminal
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>r :vert term R --no-save<CR><c-w>:wincmd p<CR>

    " Render current Rmd to PDF
    autocmd FileType r,rmd,qmd nnoremap <buffer> ZT :!R --quiet -e 'rmarkdown::render("<C-r>%", output_format="pdf_document")'<CR>


    " Perform actions on the word under cursor
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>d :call Raction("dim")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>h :call Raction("head")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>s :call Raction("str")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>p :call Raction("print")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>n :call Raction("names")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>f :call Raction("length")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>g :call Raction("glimpse")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>b :call Raction("dt")<CR>

" Normal mode mapping for <localleader>e
nnoremap <silent> <C-e>  :call AddPipeAndNewLine()<CR>

" Insert mode mapping for <localleader>e
inoremap <silent> <C-e> <Esc>:call AddPipeAndNewLine()<CR>i

function! AddPipeAndNewLine()
    " Append '|>' to the end of the current line
    normal! A |>
    " Insert a new line and move the cursor there
    normal! o
    " Insert two spaces for indentation
    normal! i  
endfunction

    " Submit the selected text as embedded and display output as comments
    autocmd FileType r,rmd,qmd vnoremap <buffer> <localleader>z :call Sel() \| :call SubmitEmbed() \| :call Rd()<CR><CR>
augroup END
