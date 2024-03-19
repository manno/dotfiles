" --- Filetype detection
"
" ----- Don't execute this file
if exists("did_load_filetypes")
    finish
endif

" ----- Assign syntax by filename
"
augroup filetypedetect
    autocmd BufRead,BufNewFile *.coffee       setf coffee
    autocmd BufRead,BufNewFile *.es6          setf javascript
    autocmd BufRead,BufNewFile *.jbuilder     setf ruby
    autocmd BufRead,BufNewFile *.mirah        setf ruby
    autocmd BufRead,BufNewFile *.nfo          setf nfo
    autocmd BufRead,BufNewFile *.prawn        setf ruby
    autocmd BufRead,BufNewFile *.prolog       setf prolog
    autocmd BufRead,BufNewFile *.rhtml        setf eruby
    autocmd BufRead,BufNewFile *.tt           setf html
    autocmd BufRead,BufNewFile *.txt          setf text
    autocmd BufRead,BufNewFile *.wiki         setf Wikipedia
    autocmd BufRead,BufNewFile *.xwt          setf xml
    autocmd BufRead,BufNewFile PKGBUILD       setf sh
    autocmd BufRead,BufNewFile svn-commit.*   setf svn
    autocmd BufRead,BufNewFile svn-log.*      setf svn
augroup END
