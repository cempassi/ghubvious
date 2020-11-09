function! NvimGitstatus()
	lua for k in pairs(package.loaded) do if k:match("^nvim%-gitstatus") then package.loaded[k] = nil end end
	lua require("nvim-gitstatus").gitstatus.gitstatus()
endfunction

augroup nvim-gitstatus
	autocmd!
	autocmd VimResized * :lua require("nvim-gitstatus").onResize()
augroup END

nnoremap <Plug>GitstatusOpen 	:lua require("nvim-gitstatus").gitstatus.gitstatus()<cr>
nnoremap <Plug>GitstatusToggle 	:lua require("nvim-gitstatus").gitstatus.toggle()<cr>

map <leader>gg <Plug>GitstatusToggle
