local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

cmd 'packadd paq-nvim' -- load the package manager

require 'paq-nvim' {
  'savq/paq-nvim';

  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' };
  'nvim-treesitter/playground';

  'neovim/nvim-lspconfig';

  'hrsh7th/nvim-compe';

  'moll/vim-bbye';

  -- dependencies for telescope
  'nvim-lua/popup.nvim';
  'nvim-lua/plenary.nvim';
  -- telescope
  'nvim-telescope/telescope.nvim';

  'scrooloose/nerdcommenter';

  'tpope/vim-surround';

  -- colors
  'fatih/molokai';
  'altercation/vim-colors-solarized';
  'NLKNguyen/papercolor-theme';
}

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

opt.termguicolors = true

opt.background = 'dark'
cmd 'color molokai'
