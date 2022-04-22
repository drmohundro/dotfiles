local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options
local api = vim.api

if not g.vscode then
  require('plugins')
end

require('options')
require('mappings')

if not g.vscode then
  require('config.treesitter')
  require('config.lualine')
  require('config.lspconfig')
  require('config.cmp')
  require('config.telescope')
end

local yankGrp = api.nvim_create_augroup('HighlightYank', { clear = true })
api.nvim_create_autocmd('TextYankPost', {
  command = 'silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=700})',
  group = yankGrp,
})

if not g.vscode then
  opt.termguicolors = true

  cmd([[colorscheme tokyonight]])

  -- NOTE: to go back to onedark
  -- require('onedark').load()
end
