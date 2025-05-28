vim.opt.runtimepath:prepend('~/.vim')
vim.opt.runtimepath:append('~/.vim/after')
vim.opt.packpath = vim.opt.runtimepath:get()
vim.cmd('source ~/.vimrc')

local function on_attach(client)
  local workspace = vim.lsp.buf.list_workspace_folders()[1]
  if workspace ~= nil then
    print(
      "LSP client attached:",
      client.name .. "@" .. workspace
    )
  else
    print("LSP client attached:", client.name)
  end
  -- Default, see: https://github.com/neovim/neovim/issues/26078
  vim.diagnostic.config{ update_in_insert = false }
  vim.opt.signcolumn = 'yes' -- Always show gutter to avoid thrash

  vim.keymap.set('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
  vim.keymap.set('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
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
      vim.snippet.expand(args.body) -- Native Neovim snippets (req v0.10+)
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

-- npm i -g bash-language-server
require'lspconfig'.bashls.setup{
  on_attach = on_attach,
  filetypes = { 'bash', 'zsh' },
}

require'lspconfig'.gopls.setup{
  cmd = { '/Users/astabile/go/bin/gopls' },
  on_attach = on_attach,
  -- see: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  settings = {
    gopls = {
      semanticTokens = true,
    },
  },
}

-- brew install lua-language-server
require'lspconfig'.lua_ls.setup{
  on_attach = on_attach,
  -- Make the server aware of plugins and other runtime files
  -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        version = 'LuaJIT' -- Neovim uses LuaJIT
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      }
    })
  end,
  settings = {
    Lua = {}
  }
}

-- npm i -g vim-language-server
require'lspconfig'.vimls.setup{
  on_attach = on_attach
}

local capabilities = require'cmp_nvim_lsp'.default_capabilities()
require'lspconfig'.ts_ls.setup{
  on_attach = on_attach,
  on_init = function(client)
    -- Disable LSP's syntax highlighting
    client.server_capabilities.semanticTokensProvider = nil
    -- Disable formatting to avoid conflict with prettier
    client.server_capabilities.documentFormattingProvider = false
    -- no `implementationProvider` responses from this LSP to avoid conflicting with css modules
    -- (use definition instead)
    client.server_capabilities.implementationProvider = false
  end,
  capabilities = capabilities,
  settings = {
    -- 80001: "File is a CommonJS module..."
    diagnostics = { ignoredCodes = { 80001 } },
  },
  -- See https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
  init_options = {
    maxTsServerMemory = 10240,
    typescript = {
      tsdk = "node_modules/typescript/lib",
      enablePromptUseWorkspaceTsdk = true,
    },
  }
}

-- npm i -g vscode-langservers-extracted@4.8.0
-- Broadcast snippet capability for completion
local css_capabilities = vim.lsp.protocol.make_client_capabilities()
css_capabilities.textDocument.completion.completionItem.snippetSupport = true
require'lspconfig'.cssls.setup{
  capabilities = css_capabilities,
}
require'lspconfig'.eslint.setup{
  -- See https://github.com/Microsoft/vscode-eslint#settings-options for all options.
  settings = {
    packageManager = 'pnpm',
    execArgv = '--max-old-space-size=8192',
  },
}

-- npm i -g cssmodules-language-server
-- Go to definition, hover for cssmodules referenced in JS
require'lspconfig'.cssmodules_ls.setup{
  on_attach = function (client)
    -- no `definitionProvider` responses from this LSP to avoid conflicting with TS
    client.server_capabilities.definitionProvider = false
    on_attach(client)
  end,
  filetypes = { 'typescriptreact' },
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
    typescriptreact = { prettierd_format },
    ["*"] = {
      require('formatter.filetypes.any').remove_trailing_whitespace,
    },
  }
})

-- Load custom :References command to integrate fzf + lsp
require'fzf-lsp-references'
