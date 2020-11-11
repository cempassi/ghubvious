" in plugin/whid.vim
if exists('g:loaded_gitstatus') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

augroup gitstatus
	autocmd!
augroup END

nnoremap <Plug>GitstatusOpen 	:lua require'gitstatus'.gitstatus()<cr>
nnoremap <Plug>GitstatusToggle 	:lua require'gitstatus'.toggle()<cr>
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
map <leader>gg <Plug>GitstatusToggle

"Explicit plugin reload, for development
map <leader>gr :call gitstatus#reload()<cr>

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_gitstatus = 1
