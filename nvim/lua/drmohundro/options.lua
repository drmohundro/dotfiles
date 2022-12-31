local opt = vim.opt -- to set options

vim.g.mapleader = ','

opt.number = true
opt.relativenumber = true

opt.smartindent = true
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
opt.undofile = true

opt.termguicolors = true

opt.scrolloff = 8
opt.signcolumn = 'yes'
opt.isfname:append('@-@')

opt.clipboard = 'unnamed'
opt.hidden = true
opt.ignorecase = true
opt.smartcase = true
opt.wildmode = 'longest,list'

opt.updatetime = 750

opt.colorcolumn = '80'

opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true

opt.cmdheight = 2

-- opt.listchars = { tab = '»\t', trail = '·', eol = '↲' }
vim.cmd('set listchars=tab:»\\ ,trail:·,eol:↲')
opt.modeline = false
opt.showbreak = '>\\'
opt.winaltkeys = 'no'
opt.inccommand = 'split'

opt.completeopt = 'menuone,noselect'

opt.mouse = 'a'

vim.g.nvim_tree_side = 'right'

-- related to the nvim-ufo plugin
vim.wo.foldcolumn = '1'
vim.wo.foldlevel = 99
vim.wo.foldenable = true
