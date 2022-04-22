-- NOTE: see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
-- see also https://github.com/williamboman/nvim-lsp-installer

-- keymaps
local on_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.keymap.set('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.keymap.set('n', 'gk', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.keymap.set('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.keymap.set('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.keymap.set('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.keymap.set('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.keymap.set('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.keymap.set('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.keymap.set('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.keymap.set('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.keymap.set('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.keymap.set('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    vim.keymap.set('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  elseif client.resolved_capabilities.document_range_formatting then
    vim.keymap.set('n', '<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    local lspDocumentHighlight = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
    vim.api.nvim_create_autocmd('CursorHold', {
      command = 'lua vim.lsp.buf.document_highlight()',
      group = lspDocumentHighlight,
    })

    vim.api.nvim_create_autocmd('CursorMoved', {
      command = 'lua vim.lsp.buf.clear_references()',
      group = lspDocumentHighlight,
    })
  end
end

-- config that activates keymaps and enables snippet support
local function make_config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return {
    -- enable snippet support
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = on_attach,
  }
end

local lsp_installer = require('nvim-lsp-installer')

lsp_installer.on_server_ready(function(server)
  local opts = make_config()

  -- (optional) Customize the options passed to the server
  if server.name == 'eslint' or server.name == 'tsserver' or server.name == 'stylelint_lsp' then
    -- this is to avoid LSP formatting conflicts with null-ls... see https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
    opts.on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end

  -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
  server:setup(opts)
  vim.cmd([[ do User LspAttachBuffers ]])
end)
