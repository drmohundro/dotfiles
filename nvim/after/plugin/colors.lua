if vim.g.vscode then
  return
end

-- vim.cmd([[colorscheme tokyonight]])
vim.g.catppuccin_flavour = 'macchiato' -- latte, frappe, macchiato, mocha
vim.cmd([[colorscheme catppuccin]])

-- NOTE: to go back to onedark
-- require('onedark').load()

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
