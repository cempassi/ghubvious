function! gitstatus#handler(job_id, data, event)
	let g:gitstatusdata = a:data
	let g:gitstatusevent = a:event
	lua require'gitstatus'.job.handler()
endfunction

function! gitstatus#update()
	lua require'gitstatus'.update(0)
endfunction

function! gitstatus#reload()
	lua for k in pairs(package.loaded) do if k:match("^gitstatus") then package.loaded[k] = nil end end
endfunction
