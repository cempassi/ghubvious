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
	print(type(error))
	print(data)
	assert(not error, error)
	if data then
		append(data)
	end
end

function job.start(args, action, ...)
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)
	local cmdargs = {...}
	handle = vim.loop.spawn('git',{
		args = args,
		stdio = {stdout, stderr},
		env = {
			GIT_EDITOR = [[nvr -cc split --remote-wait]]
		}
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

function job.display(command)
	job.start(command, window.update, 0, lines)
end

function job.run(command)
	local function writemsg()
		for _, values in pairs(lines) do
			vim.api.nvim_out_write(values)
		end
		local count = #lines
		for i=0, count do lines[i] = nil end
		job.display({'status'})
	end
	job.start(command, writemsg)
	history.update(command)
end

return job
