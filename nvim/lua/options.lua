local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options

g.mapleader = ','

opt.clipboard = 'unnamed'
opt.hidden = true
opt.ignorecase = true
opt.number = true
opt.smartcase = true
opt.wildmode = 'longest,list'

opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true

opt.cmdheight = 2

opt.listchars = { tab = '»\t', trail = '·', eol = '↲' }
opt.modeline = false
opt.showbreak = '>\\'
opt.winaltkeys = 'no'
opt.inccommand = 'split'

opt.completeopt = 'menuone,noselect'

g.nvim_tree_side = 'right'
