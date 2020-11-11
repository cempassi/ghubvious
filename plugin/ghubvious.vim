" in plugin/whid.vim
if exists('g:loaded_ghubvious') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

nnoremap <Plug>Ghubvious 	:lua require'ghubvious'.ghubvious()<cr>
nnoremap <Plug>GhubviousToggle 	:lua require'ghubvious'.toggle()<cr>

autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

map <leader>gg <Plug>GhubviousToggle

"Explicit plugin reload, for development
map <leader>gr :call ghubvious#reload()<cr>

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_ghubvious = 1
