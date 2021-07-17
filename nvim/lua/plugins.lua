local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- plugin management
  use { 'wbthomason/packer.nvim' }

  -- treesitter (LSP)
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' };
  use 'nvim-treesitter/playground'

  -- LSP config
  use 'neovim/nvim-lspconfig'

  -- completion
  use 'hrsh7th/nvim-compe'

  -- footer support
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- close buffers without messing up window layout
  use 'moll/vim-bbye'

  -- s plus motion to jump around
  use 'justinmk/vim-sneak'

  -- colorizer
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  }

  -- find files, buffers, etc.
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- commenting code
  use 'scrooloose/nerdcommenter'

  -- git support
  use {
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('neogit').setup({})
    end,
  }

  -- git signs
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require('gitsigns').setup()
    end,
  }

  -- surround motion
  use 'tpope/vim-surround'

  -- most recently used
  use 'yegappan/mru'

  -- colors
  use 'fatih/molokai'
  use 'altercation/vim-colors-solarized'
  use 'NLKNguyen/papercolor-theme'
end)
