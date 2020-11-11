function! ghubvious#reload()
	lua for k in pairs(package.loaded) do if k:match("^ghubvious") then package.loaded[k] = nil end end
endfunction
