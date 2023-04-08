if vim.g.vscode then
  return
end

local zenmode = require('zen-mode')

zenmode.setup({
  window = {
    width = 90,
    options = {
      number = true,
      relativenumber = true,
    },
  },
})

vim.keymap.set('n', '<leader>zz', function()
  zenmode.toggle()
  vim.wo.wrap = false
end)
