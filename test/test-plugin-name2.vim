
" Test cases for plugin functionality using Vader.vim
Exec 'set rtp+=' . expand('<sfile>:p:h:h')

" Test: SelectChunk selects a markdown chunk
Vader! {-> SelectChunk()}
Given a buffer with markdown chunks
  ```
  ```{r}
  print("Hello, world!")
  ```
  ```
When executing :call SelectChunk()
Then the selection should include the markdown chunk
End

" Test: MoveNextChunk moves to the next markdown chunk
Vader! {-> MoveNextChunk()}
Given a buffer with multiple markdown chunks
  ```
  ```{r}
  x <- 42
  ```
  ```
When executing :call MoveNextChunk()
Then the cursor should move to the next markdown chunk
End

" Test: MovePrevChunk moves to the previous markdown chunk
Vader! {-> MovePrevChunk()}
Given a buffer with multiple markdown chunks
  ```
  ```{r}
  y <- 99
  ```
  ```
When executing :call MovePrevChunk()
Then the cursor should move to the previous markdown chunk
End

" Test: Raction sends the correct command to the terminal
Vader! {-> Raction()}
Given a cursor on a word "head"
When executing :call Raction("head")
Then the terminal should receive "head(head)"
End

" Test: SubmitLine sends the current line to the terminal
Vader! {-> SubmitLine()}
Given a line with code `print("Hello")`
When executing :call SubmitLine()
Then the terminal should receive `print("Hello")`
End

" Test: GetVisualSelection returns the selected text
Vader! {-> GetVisualSelection()}
Given a visual selection from "Hello" to "World"
When executing :call GetVisualSelection('v')
Then the returned text should be "Hello
World"
End

" Test: SelectChunk handles no markdown chunks gracefully
Vader! {-> SelectChunk() when no markdown chunks exist}
Given an empty buffer
When executing :call SelectChunk()
Then an error message should appear
End

" Test: MoveNextChunk does not move past the last chunk
Vader! {-> MoveNextChunk() when at the last chunk}
Given a buffer with only one markdown chunk
  ```
  ```{r}
  print("End")
  ```
  ```
When executing :call MoveNextChunk()
Then the cursor should not move
End

" Test: MovePrevChunk does not move before the first chunk
Vader! {-> MovePrevChunk() when at the first chunk}
Given a buffer with only one markdown chunk
  ```
  ```{r}
  print("Start")
  ```
  ```
When executing :call MovePrevChunk()
Then the cursor should not move
End

" Test: Raction handles an invalid word gracefully
Vader! {-> Raction() with an invalid word}
Given a cursor on an invalid word
When executing :call Raction("dim")
Then an error message should appear
End
