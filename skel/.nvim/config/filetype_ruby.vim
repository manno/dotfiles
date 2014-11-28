"-----------------------------------------------------------
set foldmethod=manual
set ts=2 sw=2
"-----------------------------------------------------------
" RUBY MACROS 
"
"@c      ruby class
let @c = "vecclass \<ESC>po\<CR>def initialize\<CR>end\<CR>end\<CR>\<ESC>"

" ruby MAPS
" quick insert - simple ruby header
map  _r         :1<CR>O#!/usr/bin/ruby<ESC>o# Description: FIXME<ESC>o# Usage: <ESC><CR>O<ESC>


map  _hr        :s/:\([a-z_]*\) =>/\1:/g<CR>

" Make those debugger statements painfully obvious
au BufEnter *.rb syn match error contained "\<binding.pry\>"
au BufEnter *.rb syn match error contained "\<debugger\>"
