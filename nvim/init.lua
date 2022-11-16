local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options
local api = vim.api

if not g.vscode then
  require('plugins')
end

require('options')

if not g.vscode then
  require('mason').setup({
    ensure_installed = {
      'sumneko_lua',
      'eslint',
      'tsserver',
      'stylelint_lsp',
    },
  })

  require('config.lualine')

  local lsp_mapping = require('mappings')

  local lsp = require('lsp-zero')
  lsp.set_preferences({
    suggest_lsp_servers = true,
    setup_servers_on_start = true,
    set_lsp_keymaps = false,
    configure_diagnostics = true,
    cmp_capabilities = true,
    manage_nvim_cmp = true,
    call_servers = 'local',
    sign_icons = {
      error = '✘',
      warn = '▲',
      hint = '⚑',
      info = '',
    },
  })

  lsp.on_attach(function(_, bufnr)
    lsp_mapping.set_lsp_keymaps(bufnr)
  end)

  lsp.configure('sumneko_lua', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim', 'use' },
        },
      },
    },
  })

  lsp.setup()

  require('config.cmp')
  require('config.telescope')
end

require('mappings')

local yankGrp = api.nvim_create_augroup('HighlightYank', { clear = true })
api.nvim_create_autocmd('TextYankPost', {
  command = 'silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=700})',
  group = yankGrp,
})

if not g.vscode then
  opt.termguicolors = true

  -- cmd([[colorscheme tokyonight]])
  vim.g.catppuccin_flavour = 'macchiato' -- latte, frappe, macchiato, mocha
  vim.cmd([[colorscheme catppuccin]])

  -- NOTE: to go back to onedark
  -- require('onedark').load()
end
