local commands = require('commands')
local window = require('window')
local job = require('job')

local gitstatus = {}
gitstatus.job = require('job')

local api = vim.api
local fn = vim.fn
local previous_window, previous_cursor

local function merge_table(dest, src)
	for k,v in pairs(src) do dest[k] = v end
end

local function merge_packages()
	merge_table(gitstatus, commands)
	return gitstatus
end

-- Save current cursor position for further use
local function save_previous()
	previous_window = api.nvim_get_current_win()
	previous_cursor = api.nvim_win_get_cursor(previous_window)
end

-- Restore cursor to previous position
function gitstatus.restore()
	api.nvim_set_current_win(previous_window)
	api.nvim_win_set_cursor(previous_window, previous_cursor)
end

function gitstatus.gitstatus()
	save_previous()
	window.open()
	job.display('git', {'status'})
end

function gitstatus.toggle()
	if fn.bufexists("gitstatus") == 1 then
		window.close()
	else
		save_previous()
		window.open()
		job.display('git', {'status'})
	end
end

return merge_packages()
