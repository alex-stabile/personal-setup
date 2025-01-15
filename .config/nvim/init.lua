vim.opt.runtimepath:prepend('~/.vim')
vim.opt.runtimepath:append('~/.vim/after')
vim.opt.packpath = vim.opt.runtimepath:get()
vim.cmd('source ~/.vimrc')

local on_attach = function(client)
  print(
    "LSP client attached:",
    client.name .. "@" .. vim.lsp.buf.list_workspace_folders()[1]
  )
  if client.name == 'ts_ls' then
    -- Disable LSP's syntax highlighting
    client.server_capabilities.semanticTokensProvider = nil
    -- Disable formatting to avoid conflict with prettier
    client.server_capabilities.documentFormattingProvider = false
  end
  -- Default, see: https://github.com/neovim/neovim/issues/26078
  vim.diagnostic.config{ update_in_insert = false }
  vim.opt.signcolumn = 'yes' -- Always show gutter to avoid thrash

  vim.keymap.set('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
  vim.keymap.set('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
  vim.keymap.set('n','gr','<cmd>References<CR>')
  vim.keymap.set('n','gR','<cmd>lua vim.lsp.buf.references()<CR>')
  vim.keymap.set('n','[g','<cmd>lua vim.diagnostic.goto_prev()<CR>')
  vim.keymap.set('n',']g','<cmd>lua vim.diagnostic.goto_next()<CR>')
  vim.keymap.set('n','gk','<cmd>lua vim.diagnostic.open_float()<CR>')
end

-- Set up nvim-cmp
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

-- Set up language servers
-- vim.lsp.set_log_level('debug') -- Include logs from attached language servers
local capabilities = require'cmp_nvim_lsp'.default_capabilities()
require'lspconfig'.ts_ls.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  -- See https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
  init_options = {
    maxTsServerMemory = 10240,
  }
}

-- npm i -g vscode-langservers-extracted@4.8.0
require'lspconfig'.eslint.setup{
  -- See https://github.com/Microsoft/vscode-eslint#settings-options for all options.
  settings = {
    -- debug = true,
    packageManager = 'pnpm',
    execArgv = '--max-old-space-size=8192',
  },
}

-- Set up formatting
local function prettierd_format()
  return {
    exe = "prettierd",
    args = {vim.api.nvim_buf_get_name(0)},
    stdin = true
  }
end
-- npm i -g @fsouza/prettierd
-- Example: cat file.ts | prettierd file.ts
require'formatter'.setup({
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    javascript = { prettierd_format },
    typescript = { prettierd_format },
    ["*"] = {
      require('formatter.filetypes.any').remove_trailing_whitespace,
    },
  }
})

-- Load custom :References command to integrate fzf + lsp
require'fzf-lsp-references'
