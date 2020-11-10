function! GitstatusReload()
	lua for k in pairs(package.loaded) do if k:match("^gitstatus") then package.loaded[k] = nil end end
endfunction

function! gitstatus#handler(job_id, data, event)
	let g:gitstatusdata = a:data
	let g:gitstatusevent = a:event
	lua require'gitstatus'.job.handler()
endfunction

function! gitstatus#update()
	lua require'gitstatus'.update(0)
endfunction

augroup gitstatus
	autocmd!
augroup END

nnoremap <Plug>GitstatusOpen 	:lua require'gitstatus'.gitstatus()<cr>
nnoremap <Plug>GitstatusToggle 	:lua require'gitstatus'.toggle()<cr>

map <leader>gg <Plug>GitstatusToggle
map <leader>gr :call GitstatusReload()<cr>
