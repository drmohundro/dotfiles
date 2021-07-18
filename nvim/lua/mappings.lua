local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- toggle showing whitespace
map('n', '<leader>s', ':set nolist!<cr>', { silent = true })

map('n', 'J', '<c-d>')
map('x', 'J', '<c-d>')
map('n', 'K', '<c-u>')
map('x', 'K', '<c-u>')

-- up/down work as expected with word wrapping on
map('n', 'j', 'gj')
map('n', 'k', 'gk')
map('n', 'gj', 'j')
map('n', 'gj', 'j')

map('', 'H', '^')
map('', 'L', '$')

-- clear search highlighting
map('n', '<esc>', ':nohlsearch<cr><esc>', { silent = true })

map('', '\\\\', '<plug>NERDCommenterInvert', { noremap = false })

map('', '<c-l>', ':Telescope buffers<cr>')
map('', '<c-p>', ':Telescope find_files<cr>')
