local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

require('plugins')
require('options')
require('mappings')

require('treesitter')

opt.termguicolors = true

opt.background = 'dark'
cmd 'color molokai'
