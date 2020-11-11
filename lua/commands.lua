local commands = {}
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

function commands.stage()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	local line = api.nvim_get_current_line()
	if validate_path(file) == true then
		job.run("git", {"add", file})
	elseif fn.match(line, "supprimé") ~= -1 then
		job.run("git", {"add", file})
	end
end

function commands.unstage()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	if validate_path(file) == true then
		job.run("git", {"restore", "--staged", file})
		api.nvim_command("noh")
	end
end

function commands.ignore()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	if (validate_path(file) == true and validate_path(".gitignore")) or validate_path(".git") then
		job.run("echo", {file, ">>", ".gitignore"})
		api.nvim_command("noh")
	else
		print("Ignore only works in root directory")
	end
end

function commands.remove()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	if validate_path(file) == true then
		print("Trying to remove: " .. file)
		job.run("git", {"rm", "-f", file})
		api.nvim_command("noh")
	end
end

function commands.commit(opt)
	window.close()
	local cmd = {"commit"}
	if opt == "amend" then
		table.insert(cmd, "--amend")
	elseif cmd == "noedit" then
		table.insert(cmd, "--amend")
		table.insert(cmd, "--no-edit")
	end
	job.run("git", cmd)
end

return commands
