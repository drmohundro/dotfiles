-- bootstrap plugins
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require('lazy').setup({
  -- improve the default vim.ui interfaces
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },

  -- treesitter
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  'nvim-treesitter/playground',

  -- lsp
  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      -- LSP Support
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Autocompletion
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',

      -- Snippets
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
  },
  'nvim-lua/lsp-status.nvim',

  -- buffer/tab line
  {
    'akinsho/bufferline.nvim',
    branch = 'main',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('bufferline').setup({})
    end,
  },

  'hrsh7th/cmp-nvim-lsp-signature-help',

  {
    'folke/trouble.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    event = 'VeryLazy',
    config = function()
      require('trouble').setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  },

  -- undo tree
  'mbbill/undotree',

  -- footer support
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
  },

  -- highlight TODOs
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
      require('todo-comments').setup()
    end,
  },

  -- pane showing symbols
  {
    'simrat39/symbols-outline.nvim',
    config = function()
      require('symbols-outline').setup()
    end,
  },

  -- scrollbar in terminal
  'dstein64/nvim-scrollview',

  -- updated folds support
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'VeryLazy',
    config = function()
      require('ufo').setup()
    end,
  },

  -- toggle terminal
  {
    'akinsho/toggleterm.nvim',
    branch = 'main',
  },

  -- which key plugin
  'folke/which-key.nvim',

  -- like nerd tree
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup({})
    end,
  },

  -- close buffers without messing up window layout
  'moll/vim-bbye',

  'editorconfig/editorconfig-vim',

  -- ident lines
  'lukas-reineke/indent-blankline.nvim',

  -- autopairs
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  -- s plus motion to jump around (like vim-sneak)
  {
    'ggandor/leap.nvim',
    config = function()
      require('leap').set_default_keymaps()
    end,
  },

  -- colorizer
  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  -- find files, buffers, etc.
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
    },
    module_patterns = 'telescope*',
    config = function()
      require('telescope').load_extension('live_grep_args')
    end,
  },

  -- use fzf-native matcher instead
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  -- commenting code
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = function()
      require('Comment').setup()
    end,
  },

  -- zen/focus mode
  'folke/zen-mode.nvim',

  -- notifications
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
      vim.notify = require('notify')
    end,
  },

  -- git support
  'tpope/vim-fugitive',
  {
    'TimUntersberger/neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
    config = function()
      require('neogit').setup({})
    end,
  },

  -- git signs
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    event = 'VeryLazy',
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- diff support
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',
  },

  -- logging
  'tjdevries/vlog.nvim',

  -- surround motion
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },

  -- most recently used
  { 'yegappan/mru', event = 'VeryLazy' },

  {
    'jose-elias-alvarez/null-ls.nvim',
    config = function()
      local null_ls = require('null-ls')

      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics

      null_ls.setup({
        sources = {
          formatting.prettier,
          formatting.rustfmt,
          formatting.stylelint,
          formatting.stylua,
          formatting.terraform_fmt,
          formatting.black,

          diagnostics.cspell,
          diagnostics.eslint,
          diagnostics.luacheck,
          diagnostics.proselint,
          diagnostics.vale,
        },
        on_attach = function(client)
          if client.server_capabilities.documentFormattingProvider then
            vim.cmd([[
                augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
                augroup END
                ]])
          end
        end,
      })
    end,
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  },

  -- search for visually selected text
  { 'bronson/vim-visual-star-search', event = 'VeryLazy' },

  -- colors
  'fatih/molokai',
  'altercation/vim-colors-solarized',
  'NLKNguyen/papercolor-theme',
  'navarasu/onedark.nvim',
  'folke/tokyonight.nvim',

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      require('catppuccin').setup()
    end,
  },
})
