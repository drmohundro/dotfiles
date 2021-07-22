local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local opt = vim.opt -- to set options

require('plugins')
require('options')
require('mappings')

require('config.treesitter')
require('config.lualine')
require('config.formatter')

require('config.lspconfig')
require('config.compe')

cmd(
  [[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.rs,*.lua FormatWrite
augroup END
]],
  true
)

-- via http://stackoverflow.com/questions/2400264/is-it-possible-to-apply-vim-configurations-without-restarting/2400289#2400289 and @nelstrom
cmd([[
augroup AutoSave
  autocmd!
  autocmd BufWritePost init.lua source $MYVIMRC
augroup END
]])

opt.termguicolors = true

opt.background = 'dark'
cmd('color molokai')
