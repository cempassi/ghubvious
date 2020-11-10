local window = {}
local job = require('job')
local api = vim.api
local fn = vim.fn
local current, buffer, border, cursor
local position = 0

local function create_buffer()
	buffer = api.nvim_create_buf(false, true) --create new buffer

	--set buffer options
	api.nvim_buf_set_name(buffer, "gitstatus")
	api.nvim_buf_set_option(buffer, "filetype", "gitstatus")
	api.nvim_buf_set_option(buffer, "syntax", "gitstatus")
	api.nvim_buf_set_option(buffer, 'swapfile', false)
	api.nvim_buf_set_option(buffer, "buftype", "nofile")
	api.nvim_buf_set_option(buffer, "bufhidden", "wipe")

	--set buffer mappings
	local mappingOpts = {noremap = true, silent = true }
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusStage', ':lua require\'gitstatus\'.stage()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusUnstage', ':lua require\'gitstatus\'.unstage()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusCommit', ':lua require\'gitstatus\'.commit("")<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusCommitAmend', ':lua require\'gitstatus\'.commit("amend")<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusCommitNoedit', ':lua require\'gitstatus\'.commit("noedit")<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusIgnore', ':lua require\'gitstatus\'.ignore()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', '<Plug>GitstatusRemove', ':lua require\'gitstatus\'.remove()<cr>', mappingOpts)
	api.nvim_buf_set_keymap(buffer, 'n', 'h', ':lua require\'gitstatus\'.job.history()<cr>', mappingOpts)

	api.nvim_buf_set_keymap(buffer, 'n', 'a', '<Plug>GitstatusStage', {})
	api.nvim_buf_set_keymap(buffer, 'n', 'u', '<Plug>GitstatusUnstage', {})
	api.nvim_buf_set_keymap(buffer, 'n', 'cm', '<Plug>GitstatusCommit', {})
	api.nvim_buf_set_keymap(buffer, 'n', 'ca', '<Plug>GitstatusCommitAmend', {})
	api.nvim_buf_set_keymap(buffer, 'n', 'ce', '<Plug>GitstatusCommitNoedit', {})
	api.nvim_buf_set_keymap(buffer, 'n', 'i', '<Plug>GitstatusIgnor', {})
	api.nvim_buf_set_keymap(buffer, 'n', 'r', '<Plug>GitstatusRemov', {})
end

local function create_border(win_height, win_width)
	border = api.nvim_create_buf(false, true) --create border buffer

	-- border Lines filling
	local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
	local middle_line = '║' .. string.rep(' ', win_width) .. '║'
	for i=1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

	-- set bufer's (border_buf) lines from first line (0) to last (-1)
	-- ignoring out-of-bounds error (false) with lines (border_lines)
	api.nvim_buf_set_lines(border, 0, -1, false, border_lines)
end

local function get_opts()
	local opts = {}

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
	opts["main"] = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col
	}

	--set border window options
	opts["border"] = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1
	}
	return opts
end

function window.open()
	local opts = get_opts()

	create_buffer()
	create_border(opts.main.height, opts.main.width)
	api.nvim_open_win(border, true, opts.border)
	current = api.nvim_open_win(buffer, true, opts.main)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border)
	api.nvim_command('au BufWipeout <buffer> :silent lua require\'gitstatus\'.restore()')

	--highlight current line
	api.nvim_win_set_option(current, 'cursorline', true)
	api.nvim_win_set_option(current, "winhighlight", "NormalFloat:Normal")
end

function window.update(direction)
	position = position + direction
	cursor = api.nvim_win_get_cursor(window)
	if position < 0 then position = 0 end

	--set file as modifiable
	api.nvim_buf_set_option(buffer, 'modifiable', true)

	-- we will use vim systemlist function which run shell
	-- command and return result as list
	local lines = job.capture('git status')

	-- with small indentation results will look better
	-- for k, v in pairs(lines) do
	-- 	lines[k] = '  ' .. lines[k]
	-- end

	api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
	lines = nil
	api.nvim_command('g/(.*/d')
	api.nvim_command("noh")
	api.nvim_command("normal! zR")

	--set file as non modifiable
	api.nvim_buf_set_option(buffer, 'modifiable', false)
	api.nvim_win_set_cursor(current, cursor)
	api.nvim_command("")
end

function window.close()
	job.stop()
	api.nvim_win_close(window, true)
end

return window
