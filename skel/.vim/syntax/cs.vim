" Vim syntax file
" Language:	C#
" Maintainer:	Johannes Zellner <johannes@zellner.org>
" Last Change:	Mi, 13 Apr 2005 22:52:57 CEST
" Filenames:	*.cs
" $Id: cs.vim,v 1.6 2005/04/13 20:53:06 joze Exp $
"
" REFERENCES:
" [1] ECMA TC39: C# Language Specification (WD13Oct01.doc)

if exists("b:current_syntax")
    finish
endif

let s:cs_cpo_save = &cpo
set cpo&vim


" type
syn keyword csType			bool byte char decimal double float int long object sbyte short string uint ulong ushort void
" storage
syn keyword csStorage			class delegate enum interface namespace struct
" repeate / condition / label
syn keyword csRepeat			break continue do for foreach goto return while
syn keyword csConditional		else if switch
syn keyword csLabel			case default
" there's no :: operator in C#
syn match csOperatorError		display +::+
" user labels (see [1] 8.6 Statements)
syn match   csLabel			display +^\s*\I\i*\s*:\([^:]\)\@=+
" modifier
syn keyword csModifier			abstract const extern internal override private protected public readonly sealed static virtual volatile
" constant
syn keyword csConstant			false null true
" exception
syn keyword csException			try catch finally throw

" TODO:
syn keyword csUnspecifiedStatement	as base checked event fixed in is lock new operator out params ref sizeof stackalloc this typeof unchecked unsafe using
" TODO:
syn keyword csUnsupportedStatement	get set add remove value
" TODO:
syn keyword csUnspecifiedKeyword	explicit implicit

syntax region	csBlock		start="{" end="}" transparent fold

" Comments
"
" PROVIDES: @csCommentHook
"
" TODO: include strings ?
"
syn keyword csTodo		contained TODO FIXME XXX NOTE
if exists("cs_comment_strings")
  " A comment can contain csString, csCharacter and csNumber.
  " But a "*/" inside a cString in a csComment DOES end the comment!  So we
  " need to use a special type of cString: csCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syntax match	csCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syntax region csCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=cSpecial,csCommentSkip
  syntax region csComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=cSpecial
  syntax region  csCommentL	start="//" skip="\\$" end="$" keepend contains=@csCommentGroup,csComment2String,csCharacter,csNumbersCom,csSpaceError,@Spell

  if exists("cs_no_comment_fold")
    syntax region csComment	matchgroup=csCommentStart start="/\*" end="\*/" contains=@csCommentGroup,csCommentStartError,csCommentString,csCharacter,csNumbersCom,csSpaceError,@Spell
  else
    syntax region csComment	matchgroup=csCommentStart start="/\*" end="\*/" contains=@csCommentGroup,csCommentStartError,csCommentString,csCharacter,csNumbersCom,csSpaceError,@Spell fold
  endif

else
  syn region	csCommentL	start="//" skip="\\$" end="$" keepend contains=@csCommentGroup,csSpaceError,@Spell

  if exists("cs_no_comment_fold")
    syn region	csComment	matchgroup=csCommentStart start="/\*" end="\*/" contains=@csCommentGroup,csCommentStartError,csSpaceError,@Spell
  else
    syn region	csComment	matchgroup=csCommentStart start="/\*" end="\*/" contains=@csCommentGroup,csCommentStartError,csSpaceError,@Spell fold
  endif

endif
" keep a // comment separately, it terminates a preproc. conditional
syn region  csComment		start="/\*"  end="\*/" contains=@csCommentHook,csTodo
syntax match	csCommentError	display "\*/"
syntax match	csCommentStartError display "/\*"me=e-1 contained
syntax match    csComment	"//.*$" contains=@csCommentHook,csTodo

" xml markup inside '///' comments
syn cluster xmlRegionHook	add=csXmlCommentLeader
syn cluster xmlCdataHook	add=csXmlCommentLeader
syn cluster xmlStartTagHook	add=csXmlCommentLeader
syn keyword csXmlTag		contained Libraries Packages Types Excluded ExcludedTypeName ExcludedLibraryName
syn keyword csXmlTag		contained ExcludedBucketName TypeExcluded Type TypeKind TypeSignature AssemblyInfo
syn keyword csXmlTag		contained AssemblyName AssemblyPublicKey AssemblyVersion AssemblyCulture Base
syn keyword csXmlTag		contained BaseTypeName Interfaces Interface InterfaceName Attributes Attribute
syn keyword csXmlTag		contained AttributeName Members Member MemberSignature MemberType MemberValue
syn keyword csXmlTag		contained ReturnValue ReturnType Parameters Parameter MemberOfPackage
syn keyword csXmlTag		contained ThreadingSafetyStatement Docs devdoc example overload remarks returns summary
syn keyword csXmlTag		contained threadsafe value internalonly nodoc exception param permission platnote
syn keyword csXmlTag		contained seealso b c i pre sub sup block code note paramref see subscript superscript
syn keyword csXmlTag		contained list listheader item term description altcompliant altmember

syn cluster xmlTagHook add=csXmlTag

syn match   csXmlCommentLeader	+\/\/\/+    contained
syn match   csXmlComment	+\/\/\/.*$+ contains=csXmlCommentLeader,@csXml
syntax include @csXml <sfile>:p:h/xml.vim
hi def link xmlRegion Comment


" [1] 9.5 Pre-processing directives
syn region	csPreCondit
    \ start="^\s*#\s*\(define\|undef\|if\|elif\|else\|endif\|line\|error\|warning\|region\|endregion\)"
    \ skip="\\$" end="$" contains=csComment keepend



" Strings and constants
syn match   csSpecialError	contained "\\."
syn match   csSpecialCharError	contained "[^']"
" [1] 9.4.4.4 Character literals
syn match   csSpecialChar	contained +\\["\\'0abfnrtvx]+
" unicode characters
syn match   csUnicodeNumber	+\\\(u\x\{4}\|U\x\{8}\)+ contained contains=csUnicodeSpecifier
syn match   csUnicodeSpecifier	+\\[uU]+ contained
syn region  csVerbatimString	start=+@"+ end=+"+ end=+$+ skip=+""+ contains=csVerbatimSpec
syn match   csVerbatimSpec	+@"+he=s+1 contained
syn region  csString		start=+"+  end=+"+ end=+$+ contains=csSpecialChar,csSpecialError,csUnicodeNumber
syn match   csCharacter		"'[^']*'" contains=csSpecialChar,csSpecialCharError
syn match   csCharacter		"'\\''" contains=csSpecialChar
syn match   csCharacter		"'[^\\]'"
syn match   csNumber		"\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
syn match   csNumber		"\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match   csNumber		"\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match   csNumber		"\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"

" The default highlighting.
hi def link csType			Type
hi def link csStorage			StorageClass
hi def link csRepeat			Repeat
hi def link csConditional		Conditional
hi def link csLabel			Label
hi def link csModifier			StorageClass
hi def link csConstant			Constant
hi def link csException			Exception
hi def link csUnspecifiedStatement	Statement
hi def link csUnsupportedStatement	Statement
hi def link csUnspecifiedKeyword	Keyword
hi def link csOperatorError		Error

hi def link csTodo			Todo
hi def link csComment			Comment

hi def link csSpecialError		Error
hi def link csSpecialCharError		Error
hi def link csString			String
hi def link csVerbatimString		String
hi def link csVerbatimSpec		SpecialChar
hi def link csPreCondit			PreCondit
hi def link csCharacter			Character
hi def link csSpecialChar		SpecialChar
hi def link csNumber			Number
hi def link csUnicodeNumber		SpecialChar
hi def link csUnicodeSpecifier		SpecialChar

" xml markup
hi def link csXmlCommentLeader		Comment
hi def link csXmlComment		Comment
hi def link csXmlTag			Statement

let b:current_syntax = "cs"

let &cpo = s:cs_cpo_save
unlet s:cs_cpo_save

" vim: ts=8
