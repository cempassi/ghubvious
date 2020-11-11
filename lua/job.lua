local job = {}
local history = {}
local lines = {}
local window = require('window')

local api = vim.api

local function append(data)
	local values = vim.split(data, "\n")
	for _, d in pairs(values) do
		table.insert(lines, d)
	end
end

local function onread(error, data)
	assert(not error, error)
	if data then
		append(data)
	end
end

function job.start(command, args, action, ...)
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)
	local cmdargs = {...}
	vim.env.GIT_EDITOR = [[nvr -cc 'bo split' --remote-wait]]
	handle = vim.loop.spawn(command,{
		args = args,
		stdio = {stdout, stderr},
	},
	vim.schedule_wrap(function()
		stdout:read_stop()
		stderr:read_stop()
		stdout:close()
		stderr:close()
		handle:close()
		if action ~= nil then action(unpack(cmdargs)) end
	end
	)
	)
	vim.loop.read_start(stdout, onread)
	vim.loop.read_start(stderr, onread)
end

function history.update(command)
	table.insert(history, command)
end

function job.history()
	for _ , command in pairs(history) do
		api.nvim_command('echom \"' .. command)
	end
end

function job.display(command, args)
	job.start(command, args, window.update, 0, lines)
end

function job.run(command, args)
	local function writemsg()
		for _, values in pairs(lines) do
			vim.api.nvim_out_write(values)
		end
		print(vim.inspect(lines))
		local count = #lines
		for i=0, count do lines[i] = nil end
		job.display("git", {'status'})
	end
	job.start(command, args, writemsg)
	history.update(command)
end

return job
