" rgt-R.vim
" A Vim plugin for working with R and R Markdown files, sending code to an R terminal.

"------------------------------------------------------------------------------
" Configuration Options
"------------------------------------------------------------------------------
" Customize chunk delimiters and behavior
let g:rgt_chunk_delimiter = '^\s*```.*'
let g:rgt_pipe_indent = '  '
let g:rgt_terminal_selection = 1  " Allow terminal selection (1 = enabled, 0 = disabled)

"------------------------------------------------------------------------------
" Utility Functions
"------------------------------------------------------------------------------

" Check if an R terminal is available
function! rgt#has_r_terminal() abort
    let terms = term_list()
    return !empty(terms)
endfunction

" Prompt user to select a terminal
function! rgt#get_r_terminal() abort
    if !rgt#has_r_terminal()
        echo "No terminals available."
        return -1
    endif
    let terms = term_list()
    return g:rgt_terminal_selection ? inputlist(['Select R terminal:'] + terms) - 1 : 0
endfunction

" Safely send keys to the R terminal, if available
function! rgt#send_to_r(cmd) abort
    let term_index = rgt#get_r_terminal()
    if term_index < 0
        return
    endif
    let terms = term_list()
    call term_sendkeys(terms[term_index], a:cmd)
endfunction

"------------------------------------------------------------------------------
" Core Functions
"------------------------------------------------------------------------------

" Add a pipe and a new indented line
function! rgt#AddPipeAndNewLine() abort
    normal! A |>
    normal! o
    execute "normal! i" . g:rgt_pipe_indent
endfunction

" Collect all previous chunks' code
function! rgt#CollectPreviousChunks() abort
    let l:chunk_delimiter = get(g:, 'rgt_chunk_delimiter', '^\s*```.*')
    let l:current_line = line('.')
    let l:all_lines = []
    let l:start_line = 1

    for l:line in range(1, l:current_line)
        if match(getline(l:line), l:chunk_delimiter) != -1
            let l:all_lines += getline(l:start_line, l:line - 1)
            let l:start_line = l:line + 1
        endif
    endfor

    return join(l:all_lines, "\n")
endfunction

" Collect and submit all previous chunks
function! rgt#CollectAndSubmitPreviousChunks(filter = '', debug = 0) abort
    let l:previous_chunks = rgt#CollectPreviousChunks()
    if a:filter != ''
        let l:previous_chunks = join(filter(split(l:previous_chunks, "\n"), a:filter), "\n")
    endif

    if empty(l:previous_chunks)
        echom "No previous chunks to submit."
        return
    endif

    if a:debug
        echom "Submitting: " . l:previous_chunks
    endif

    call rgt#send_to_r(l:previous_chunks . "\n")
    echom "Submitted all previous chunks to R."
endfunction

" Move to the next chunk
function! rgt#MoveNextChunk() abort
    if search(get(g:, 'rgt_chunk_delimiter', '^\s*```.*'), 'W')
        normal! j
    else
        echom "No further chunks found."
    endif
    noh
endfunction

" Move to the previous chunk
function! rgt#MovePrevChunk() abort
    let l:chunk_delimiter = get(g:, 'rgt_chunk_delimiter', '^\s*```.*')

    while line('.') > 1 && getline('.') =~ l:chunk_delimiter
        execute "normal! k"
    endwhile

    let l:found = search(l:chunk_delimiter, 'bW')
    if l:found > 0
        execute l:found + 1 . "normal! 0"
    else
        echom "No previous chunk found."
    endif

    noh
endfunction

"------------------------------------------------------------------------------
" Mappings
"------------------------------------------------------------------------------
augroup RMarkdownMappings
    autocmd!
    autocmd FileType r,rmd,qmd nnoremap <buffer> <CR> :call rgt#send_to_r(getline('.') . "\n")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>c :call rgt#send_to_r("\<c-c>")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>q :call rgt#send_to_r("Q\n")<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>j :call rgt#MoveNextChunk()<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>k :call rgt#MovePrevChunk()<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <localleader>' :call rgt#CollectAndSubmitPreviousChunks()<CR>
    autocmd FileType r,rmd,qmd nnoremap <buffer> <C-e> :call rgt#AddPipeAndNewLine()<CR>
augroup END

"------------------------------------------------------------------------------
" Help Documentation (as Comments)
"------------------------------------------------------------------------------
" Mappings:
" <CR>: Submit the current line to R.
" <localleader>c: Send Ctrl-C to R (break process).
" <localleader>q: Send Q to R (exit debug browser).
" <localleader>j: Move to the next chunk.
" <localleader>k: Move to the previous chunk.
" <localleader>': Collect and submit all previous chunks to R.
" <C-e>: Add a pipe (`|>`) and a new indented line.
