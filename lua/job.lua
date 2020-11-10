local job = {}
local id = 0
local history = {}
local lines = {}
local buffer = ''
local running = false

local api = vim.api
local fn = vim.fn
local g = vim.g

api.nvim_set_var("gitstatuscapture", 0)
api.nvim_set_var("gitstatussuccess", 1)

function job.handler()
	local event = g.gitstatusevent
	local data = g.gitstatusdata
	if event == "stdout" and g.gitstatuscapture == 1 then
		lines = data
		api.nvim_set_var("gitstatuscapture", 0)
	elseif event == "stdout" and g.gitstatussuccess == 0 then
		api.nvim_set_var("gitstatussuccess", 1)
	elseif event == "stderr" then
		api.nvim_set_var("gitstatuscapture", 0)
	end
end

function job.start()
	if id ~= 0 then
		return
	end
	local callbacks = {
		on_stdout = "gitstatus#handler",
		on_stderr = "gitstatus#handler",
		on_exit = "gitstatus#handler"
	}
	id = fn.jobstart({'bash'}, callbacks)
end

function job.stop()
	fn.jobstop(id)
	id = 0
end

function history.update(command)
	table.insert(history, command)
end

function job.history()
	for cmd in history do
		api.nvim_command('echom \"' .. cmd)
	end
end

function job.capture(command)
	api.nvim_set_var("gitstatuscapture", 1)
	job.start()
	fn.chansend(id, command .. "\n" )
	vim.wait(5000, function() return vim.g.gitstatuscapture == 0 end, 500)
	return lines
end

function job.send(command)
	api.nvim_set_var("gitstatussuccess", 0)
	job.start()
	history.update(command)
	fn.chansend(id, command .. " && echo EOF\n")
	vim.wait(5000, function() return vim.g.gitstatussuccess == 1 end, 500)
	vim.cmd("call gitstatus#update()")
end

return job
