local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local g = vim.g -- a table to access global variables

cmd([[packadd packer.nvim]])

return require('packer').startup(function()
  -- plugin management
  use('wbthomason/packer.nvim')

  -- treesitter (LSP)
  use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' })
  use('nvim-treesitter/playground')

  -- LSP config
  use('neovim/nvim-lspconfig')

  -- completion and snippets
  use({
    'rafamadriz/friendly-snippets',
    event = 'InsertEnter',
  })

  use({
    'hrsh7th/nvim-cmp',
  })

  use({
    'L3MON4D3/LuaSnip',
    wants = 'friendly-snippets',
  })

  use({
    'saadparwaiz1/cmp_luasnip',
  })

  use({
    'hrsh7th/cmp-nvim-lua',
  })

  use({
    'hrsh7th/cmp-nvim-lsp',
  })

  use({
    'hrsh7th/cmp-buffer',
  })

  use({
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('trouble').setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  })

  -- footer support
  -- NOTE: using fork for now - original is hoob3rt/lualine.nvim
  use({
    'shadmansaleh/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  })

  -- scrollbar in terminal
  use('dstein64/nvim-scrollview')

  -- which key plugin
  use('folke/which-key.nvim')

  -- like nerd tree
  use('kyazdani42/nvim-tree.lua')

  -- close buffers without messing up window layout
  use('moll/vim-bbye')

  use('editorconfig/editorconfig-vim')

  -- s plus motion to jump around
  use('justinmk/vim-sneak')

  -- colorizer
  use({
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  })

  -- find files, buffers, etc.
  use({
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } },
    module_patterns = 'telescope*',
  })

  -- use fzf-native matcher instead
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

  -- commenting code
  use('preservim/nerdcommenter')
  g.NERDCreateDefaultMappings = 0

  -- notifications
  use({
    'rcarriga/nvim-notify',
    config = function()
      vim.notify = require('notify')
    end,
  })

  -- git support
  use({
    'TimUntersberger/neogit',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('neogit').setup({})
    end,
  })

  -- git signs
  use({
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('gitsigns').setup()
    end,
  })

  -- logging
  use('tjdevries/vlog.nvim')

  -- surround motion
  use('tpope/vim-surround')

  -- most recently used
  use('yegappan/mru')

  -- autoformatter
  use('mhartington/formatter.nvim')

  -- search for visually selected text
  use('bronson/vim-visual-star-search')

  -- colors
  use('fatih/molokai')
  use('altercation/vim-colors-solarized')
  use('NLKNguyen/papercolor-theme')
  use('navarasu/onedark.nvim')
end)
