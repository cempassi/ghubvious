function! ghubvious#handler(job_id, data, event)
	let g:ghubviousdata = a:data
	let g:ghubviousevent = a:event
	lua require'ghubvious'.job.handler()
endfunction

function! ghubvious#update()
	lua require'ghubvious'.update(0)
endfunction

function! ghubvious#reload()
	lua for k in pairs(package.loaded) do if k:match("^ghubvious") then package.loaded[k] = nil end end
endfunction
