local gitstatus = require('command')

local api = vim.api
local fn = vim.fn
local buffer, window, cursor
local position = 0
local previous_window, previous_cursor

local function open_window()
	buffer = api.nvim_create_buf(false, true) --create new buffer
	local border_buffer = api.nvim_create_buf(false, true) --create border buffer

	--set buffer options
	api.nvim_buf_set_name(buffer, "gitstatus")
	api.nvim_buf_set_option(buffer, "filetype", "gitstatus")
	api.nvim_buf_set_option(buffer, "syntax", "gitstatus")
	api.nvim_buf_set_option(buffer, 'swapfile', false)
	api.nvim_buf_set_option(buffer, "buftype", "nofile")
	api.nvim_buf_set_option(buffer, "bufhidden", "wipe")

	--set buffer mappings
	local mappingOpts = {noremap = true, silent = true }
	api.nvim_buf_set_keymap(buffer, 'n', 'a', ':silent lua require\'gitstatus\'.stage()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', 'u', ':silent lua require\'gitstatus\'.unstage()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', 'c', ':lua require\'gitstatus\'.commit()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', 'i', ':silent lua require\'gitstatus\'.ignore()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', 'r', ':silent lua require\'gitstatus\'.remove()<cr>', mappingOpts)

	-- get dimensions
	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	-- calculate our floating window size
	local win_height = math.ceil(height * 0.5 - 4)
	local win_width = math.ceil(width * 0.5)

	-- and its starting position
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	-- set window options
	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col
	}

	--set border window options
	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1
	}

	-- border Lines filling
	local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
	local middle_line = '║' .. string.rep(' ', win_width) .. '║'
	for i=1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

	-- set bufer's (border_buf) lines from first line (0) to last (-1)
	-- ignoring out-of-bounds error (false) with lines (border_lines)
	api.nvim_buf_set_lines(border_buffer, 0, -1, false, border_lines)

	local border_window = api.nvim_open_win(border_buffer, true, border_opts)
	window = api.nvim_open_win(buffer, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buffer)
	api.nvim_command('au BufWipeout <buffer> :silent lua require\'gitstatus\'.restore()')

	--highlight current line
	api.nvim_win_set_option(window, 'cursorline', true)
	api.nvim_win_set_option(window, "winhighlight", "NormalFloat:Normal")
end

function gitstatus.update_view(direction)
	position = position + direction
	cursor = api.nvim_win_get_cursor(window)
	if position < 0 then position = 0 end

	--set file as modifiable
	api.nvim_buf_set_option(buffer, 'modifiable', true)

	-- we will use vim systemlist function which run shell
	-- command and return result as list
	local result = fn.systemlist('git status')

	-- with small indentation results will look better
	for k, v in pairs(result) do
		result[k] = '  '..result[k]
	end

	api.nvim_buf_set_lines(buffer, 0, -1, false, result)
	api.nvim_command('g/(.*/d')
	api.nvim_command("noh")
	api.nvim_command("normal! zR")

	--set file as non modifiable
	api.nvim_buf_set_option(buffer, 'modifiable', false)
	api.nvim_win_set_cursor(window, cursor)
	api.nvim_command("")
end

local function save_previous()
	previous_window = api.nvim_get_current_win()
	previous_cursor = api.nvim_win_get_cursor(previous_window)
end

-- Restore cursor to previous position
function gitstatus.restore()
	api.nvim_set_current_win(previous_window)
	api.nvim_win_set_cursor(previous_window, previous_cursor)
end

function gitstatus.close_window()
	api.nvim_win_close(window, true)
end

function gitstatus.gitstatus()
	save_previous()
	open_window()
	gitstatus.update_view(0)
end

function gitstatus.toggle()
	if fn.bufexists("gitstatus") == 1 then
		gitstatus.close_window()
	else
		save_previous()
		open_window()
		gitstatus.update_view(0)
	end
end

return gitstatus
