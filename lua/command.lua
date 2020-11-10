local command = {}
local job = require('job')

local window = require('window')
local api = vim.api
local fn = vim.fn

local function validate_path(path)
	local result = false
	if fn.isdirectory(path) == 1 then
		result = true
	elseif fn.filereadable(path) == 1 then
		result = true
	end
	return result
end

function command.stage()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	local line = api.nvim_get_current_line()
	if validate_path(file) == true then
		job.send("git add " .. file)
	elseif fn.match(line, "supprimé") ~= -1 then
		job.send("git add " .. file)
	end
end

function command.unstage()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	if validate_path(file) == true then
		job.send("git restore --staged "..file)
		api.nvim_command("noh")
	end
end

function command.ignore()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	local append = "echo " .. file .. " >> .gitignore"
	if (validate_path(file) == true and validate_path(".gitignore")) or validate_path(".git") then
		job.send(append)
		api.nvim_command("noh")
	else
		print("Ignore only works in root directory")
	end
end

function command.remove()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	if validate_path(file) == true then
		print("Trying to remove: " .. file)
		job.send("git rm -f "..file)
		api.nvim_command("noh")
	end
end

function command.commit(opt)
	local escape = [[nvr --remote-send '<c-\><c-N><c-w><c-p>:q<cr>:q<cr>' ]]
	local cmd = [[git commit ]]
	if opt == "amend" then
		cmd = cmd .. "--amend "
	elseif cmd == "noedit" then
		cmd = cmd .. "--amend --no-edit"
	end
	job.report(escape .. " && " .. cmd)
	-- window.background()
end

return command
