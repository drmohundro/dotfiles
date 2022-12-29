if not vim.g.vscode then
  require('drmohundro.plugins')
end

require('drmohundro.options')
require('drmohundro.mappings')

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 250,
    })
  end,
})
