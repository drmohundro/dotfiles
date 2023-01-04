if vim.g.vscode then
  return
end

require('zen-mode').setup({
  window = {
    width = 90,
    options = {
      number = true,
      relativenumber = true,
    },
  },
})

vim.keymap.set('n', '<leader>zz', function()
  require('zen-mode').toggle()
  vim.wo.wrap = false
end)
