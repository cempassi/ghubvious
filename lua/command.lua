local command = {}
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
		api.nvim_command("Git add "..file)
		command.update_view(0)
	elseif fn.match(line, "supprimé") ~= -1 then
		api.nvim_command("Git add "..file)
		command.update_view(0)
	end
end

function command.unstage()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	if validate_path(file) == true then
		api.nvim_command("Git restore --staged "..file)
		command.update_view(0)
		api.nvim_command("noh")
	end
end

function command.ignore()
	api.nvim_command("normal! $")
	local file = fn.expand("<cWORD>")
	local append = "echo " .. file .. " >> .gitignore"
	if (validate_path(file) == true and validate_path(".gitignore")) or validate_path(".git") then
		os.execute(append)

		command.update_view(0)
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
		api.nvim_command("Git rm -f "..file)
		command.update_view(0)
		api.nvim_command("noh")
	end
end

function command.commit()
	command.close_window()
	fn.execute('let $GIT_EDITOR="nvr --remote-wait -cc vsplit"')
	fn.execute("Git commit")
end

return command
