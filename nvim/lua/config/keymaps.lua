-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- toggle showing whitespace
-- TOOD: this is overlapping with something else...
vim.keymap.set("n", "<leader>s", ":set nolist!<cr>", { silent = true })

-- use J/K to go half page up/down
vim.keymap.set("n", "J", "<C-d>zz")
vim.keymap.set("x", "J", "<C-d>zz")
vim.keymap.set("n", "K", "<C-u>zz")
vim.keymap.set("x", "K", "<C-u>zz")

-- the `zz` is to center results
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep search results centered
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- up/down work as expected with word wrapping on
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "gj", "j")
vim.keymap.set("n", "gj", "j")

if vim.g.vscode then
  -- HACK: get around weird issues with o|O keys in VSCode Neovim... see https://github.com/asvetliakov/vscode-neovim/issues/485#issuecomment-792292205
  vim.keymap.set("n", "o", "<cmd>call VSCodeNotify('editor.action.insertLineAfter')<cr>i", { silent = true })
  vim.keymap.set("n", "O", "<cmd>call VSCodeNotify('editor.action.insertLineBefore')<cr>i", { silent = true })
else
  vim.keymap.set("", "<C-l>", function()
    Snacks.picker.buffers()
  end, {})
  vim.keymap.set("", "<C-p>", function()
    Snacks.picker.files()
  end, {})

  vim.keymap.set("", "<C-e>", function()
    Snacks.picker.recent()
  end, {})

  vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
end
