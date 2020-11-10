local job = {}
local id = 0
local history = {}

local api = vim.api
local fn = vim.fn

function job.handler(data, event)
	if event == "stdout" then
		print("stdout: " .. data)
	elseif event == "stderr" then
		print("stdout: " .. data)
	else
		print("Exited job " .. id)
	print("Je passe bien ici!")
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
	print(vim.inspect(history))
end


function job.send(command)
	job.start()
	history.update(command)
	fn.chansend(id, command .. "\n")
end

return job
