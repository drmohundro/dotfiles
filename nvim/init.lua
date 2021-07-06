local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

cmd 'packadd paq-nvim' -- load the package manager

require 'paq-nvim' {
  'savq/paq-nvim';

  'neovim/nvim-lspconfig';
  'hrsh7th/nvim-compe';

  -- colors
  'fatih/molokai';
  'altercation/vim-colors-solarized';
  'NLKNguyen/papercolor-theme';
}

g.mapleader = ','

opt.clipboard = 'unnamed'

opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true

opt.listchars = { tab = '»\t', trail = '·', eol = '↲' }

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- toggle showing whitespace
map('n', '<leader>s', ':set nolist!<cr>', { silent = true })

map('n', 'J', '<c-d>')
map('x', 'J', '<c-d>')
map('n', 'K', '<c-u>')
map('x', 'K', '<c-u>')

map('', 'H', '^')
map('', 'L', '$')

-- clear search highlighting
map('n', '<esc>', ':nohlsearch<cr><esc>', { silent = true})

opt.termguicolors = true

opt.background = 'dark'
cmd 'color molokai'
