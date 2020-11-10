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
api.nvim_set_var("gitstatusreport", 0)
api.nvim_set_var("gitstatussuccess", 1)

local function handle_stdout(data)
	if g.gitstatuscapture == 1 then
		lines = data
		api.nvim_set_var("gitstatuscapture", 0)
	elseif g.gitstatussuccess == 0 then
		api.nvim_set_var("gitstatussuccess", 1)
		api.nvim_out_write([[Status success:]])
		for key, string in pairs(data) do
			api.nvim_out_write(string)
		end
	elseif g.gitstatusreport == 1 then
		api.nvim_out_write([[Status success:]])
		for key, string in pairs(data) do
			api.nvim_out_write(string)
		end
		api.nvim_set_var("gitstatusreport", 0)
	end
end

local function handle_stderr(data)
	api.nvim_out_write([[Errors:]])
	for key, string in pairs(data) do
		api.nvim_err_write(string)
	end
	api.nvim_set_var("gitstatussuccess", 0)
	api.nvim_set_var("gitstatusreport", 0)
	api.nvim_set_var("gitstatuscapture", 0)
end

function job.handler()
	local event = g.gitstatusevent
	local data = g.gitstatusdata

	if event == "stdout" then
		handle_stdout(data)
	elseif event == "stderr" then
		handle_stderr(data)
	else
		vim.cmd([[echomsg "Le terminal a quité"]])
	end
end

function job.start()
	if id ~= 0 then
		return
	end
	local opts = {
		on_stdout = "gitstatus#handler",
		on_stderr = "gitstatus#handler",
		on_exit = "gitstatus#handler",
		env = {
			GIT_EDITOR =[[nvr -cc split --remote-wait]]
		}
	}
	id = fn.jobstart({'bash'}, opts)
end

function job.stop()
	fn.jobstop(id)
	id = 0
end

function history.update(command)
	table.insert(history, command)
end

function job.history()
	for value, command in pairs(history) do
		api.nvim_command('echom \"' .. command)
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

function job.report(command)
	api.nvim_set_var("gitstatusreport", 1)
	job.start()
	history.update(command)
	fn.chansend(id, command .. " \n")
end

return job
