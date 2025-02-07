-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function toggle_list()
  if vim.opt.list:get() then
    vim.cmd("setlocal nolist")
    Snacks.indent.enable()
  else
    vim.cmd("setlocal list")
    Snacks.indent.disable()
  end
end

-- toggle showing whitespace
vim.keymap.set("n", "<leader>uw", toggle_list, { silent = true, desc = "Toggle whitespace" })

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

  vim.keymap.set("", "<leader>r", function()
    Snacks.picker.recent()
  end, {})

  vim.keymap.set("", "<C-e>", function()
    Snacks.picker.recent()
  end, {})

  vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
end
