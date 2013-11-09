" Vim syntax file
" Language:	PDF
" Maintainer:	Maik Musall <maik@musall.de>
" Last change:	2004-04-11

" Remove any old syntax stuff
syn clear
syntax case match

" some characters that cannot be in a pdf program (outside a string)
" syn match pdfError "<<<\|\.\.\|=>\|<>\|||=\|&&=\|->"
"syn match pdfError "<<<\|=>\|<>\|||=\|&&=\|->"

" keyword definitions
syn keyword pdfStructure		xref startxref trailer endobj stream endstream EOF

" pattern matches
syn match pdfName				/\/[A-Za-z][a-zA-Z0-9-]*/
syn match pdfObjRef				/\<[0-9]* [0-9]* R\>/
syn match pdfObjId				/\<[0-9]* [0-9]* obj\>/
syn match pdfDictionary			/(<<|>>)/
syn match pdfArray				/(\[|\])/
syn match pdfString				/(\(|\))/
syn region pdfStream			start=/\<stream\>/ end=/\<endstream\>/

" Strings and constants
"syn match   pdfNumber           "-\=\<[0-9]\+L\=\>\|0[xX][0-9a-fA-F]\+\>"

"if !exists("did_pdf_syntax_inits")
"  let did_pdf_syntax_inits = 1
  hi link pdfName					Identifier
  hi link pdfObjRef					Special
  hi link pdfObjId					Underlined
  hi link pdfDictionary				Delimiter
  hi link pdfArray					Delimiter
  hi link pdfString					Delimiter
  hi link pdfStructure				Conditional
  hi link pdfStream					Comment
  "Function Exception StorageClass Boolean Special Error Character
  "SpecialChar Operator Comment Constant Typedef SpecialComment Special
  "Type Number Include Identifier PreProc Label Repeat Statement String
  "Conditional Delimiter
"endif

let b:current_syntax = "pdf"

" vim: ts=4
