function! GitstatusReload()
	lua for k in pairs(package.loaded) do if k:match("^gitstatus") then package.loaded[k] = nil end end
endfunction

augroup gitstatus
	autocmd!
augroup END

nnoremap <Plug>GitstatusOpen 	:silent lua require'gitstatus'.gitstatus()<cr>
nnoremap <Plug>GitstatusToggle 	:silent lua require'gitstatus'.toggle()<cr>

map <leader>gg <Plug>GitstatusToggle
map <leader>gr :call GitstatusReload()<cr>
