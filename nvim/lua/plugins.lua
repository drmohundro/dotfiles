local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use { 'wbthomason/packer.nvim' }

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' };
  use 'nvim-treesitter/playground'

  use 'neovim/nvim-lspconfig'

  use 'hrsh7th/nvim-compe'

  use 'moll/vim-bbye'

  -- dependencies for telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  -- telescope
  use 'nvim-telescope/telescope.nvim'

  use 'scrooloose/nerdcommenter'

  use 'tpope/vim-surround'

  -- colors
  use 'fatih/molokai'
  use 'altercation/vim-colors-solarized'
  use 'NLKNguyen/papercolor-theme'
end)
