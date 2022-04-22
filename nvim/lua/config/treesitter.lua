require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
  },
  ensure_installed = {
    'c_sharp',
    'css',
    'dockerfile',
    'fish',
    'go',
    'json',
    'lua',
    'make',
    'markdown',
    'python',
    'regex',
    'ruby',
    'rust',
    'svelte',
    'swift',
    'toml',
    'typescript',
    'vim',
    'vue',
    'yaml',
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
  },
})
