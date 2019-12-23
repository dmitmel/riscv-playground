let s:build_dir = expand('<sfile>:h').'/build'
let &makeprg = 'make -C '.shellescape(s:build_dir)
compiler gcc
