local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options

if not g.vscode then
  require('plugins')
end

require('options')
require('mappings')

require('config.treesitter')
require('config.lualine')
require('config.formatter')
require('config.lspconfig')
require('config.compe')
require('config.telescope')

cmd(
  [[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.rs,*.lua FormatWrite
augroup END
]],
  true
)

if not g.vscode then
  opt.termguicolors = true

  require('onedark').setup()
end
