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
  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set('n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
  elseif client.server_capabilities.documentRangeFormattingProvider then
    vim.keymap.set('n', '<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
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

-- this is to avoid LSP formatting conflicts with null-ls... see https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
local function nullls_on_attach(client, bufnr, lang)
  if lang == 'eslint' or lang == 'tsserver' or lang == 'stylelint_lsp' or lang == 'sumneko_lua' then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  return on_attach(client, bufnr)
end

-- config that activates keymaps and enables snippet support
local function make_config(lang)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  local settings = {}

  -- TODO: not sure how to just use luacheck for diagnostics instead... I'm still figuring out the latest with null-ls vs lspconfig vs nvim-lsp-installer
  if lang == 'sumneko_lua' then
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
      },
    }
  end

  return {
    -- enable snippet support
    capabilities = capabilities,

    settings = settings,

    -- map buffer local keybindings when the language server attaches
    on_attach = function(client, bufnr)
      return nullls_on_attach(client, bufnr, lang)
    end,
  }
end

local lspconfig = require('lspconfig')

require('mason-lspconfig').setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    lspconfig[server_name].setup(make_config(server_name))
  end,
})

vim.cmd([[ do User LspAttachBuffers ]])
