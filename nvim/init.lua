local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options

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

cmd(
  [[
augroup HighlightYank
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END
]],
  true
)

if not g.vscode then
  opt.termguicolors = true

  require('onedark').setup()
end
