if vim.g.vscode then
  return
end

require('lualine').setup({
  options = {
    icons_enabled = true,
    -- theme = 'onedark',
    -- theme = 'tokyonight',
    theme = 'catppuccin',
  },
  extensions = {
    'nvim-tree',
  },
})
