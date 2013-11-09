"-----------------------------------------------------------
" FUNCTIONS
"
" QUIT FUNCTION
function! s:writequitall()
    write
    quitall
endfunction

" CALL FUNCTION IF DEFINED
" let lalala=FuncExists("TestFun") | echo lalala
function! FuncExists(funktion)
    let tmp=printf("*%s",a:funktion)
    if exists(tmp)
        return function(a:funktion)()
    else 
        return ''
    endif
endfunction

function! GetEncoding()
     return "[". (&fenc==""?&enc:&fenc). ((exists("+bomb") && &bomb)?",B":""). "]"
endfunction

function! MyStatusLine()
    if getbufvar('%', '&buftype') == ''
        let strFileInfo = "%<%f%h%m\ %r%y\ %{GetEncoding()}\ %k"
        let strFuncName = "%{FuncExists('Tlist_Get_Tagname_By_Line')}"
        "let strCharInfo = "\[offs=0x%04O\ val=0x%02B\]"
        let strCharInfo = "\[0x%02B\]"
        let strCursorPos = "\ (%03l,%03c)\ %P"
        return strFileInfo. "\ %=". strFuncName. "%=\ ". strCharInfo. strCursorPos
    else
        return "%f%y%=%P"
    endif
endfunction

" " The function Nr2Hex() returns the Hex string of a number.
" func Nr2Hex(nr)
"   let n = a:nr
"   let r = ""
"   while n
"     let r = '0123456789ABCDEF'[n % 16] . r
"     let n = n / 16
"   endwhile
"   return r
" endfunc

" " The function String2Hex() converts each character in a string to a two
" " character Hex string.
" func String2Hex(str)
"   let out = ''
"   let ix = 0
"   while ix < strlen(a:str)
"     let out = out . Nr2Hex(char2nr(a:str[ix]))
"     let ix = ix + 1
"   endwhile
"   return out
" endfunc
