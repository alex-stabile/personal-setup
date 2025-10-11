local function install_plugins()
  local vim = vim
  local Plug = vim.fn['plug#']
  vim.call('plug#begin')
  Plug('mason-org/mason.nvim')
  Plug('neovim/nvim-lspconfig')
  Plug('mhartington/formatter.nvim')
  Plug('nvim-treesitter/nvim-treesitter', { ['branch'] = 'master', ['build'] = ':TSUpdate'})

  Plug('junegunn/fzf')
  Plug('junegunn/fzf.vim')

  Plug('tpope/vim-fugitive')
  Plug('tpope/vim-rhubarb')

  Plug('neanias/everforest-nvim', { ['branch'] = 'main' })
  Plug('rebelot/kanagawa.nvim')
  Plug('catppuccin/nvim', {['as'] = 'catppuccin'})
  vim.call('plug#end')
end
install_plugins()

vim.o.termguicolors = true
vim.o.background = 'dark'
-- float window style
vim.o.winborder = 'bold'
-- everthing else
vim.cmd('source ../../.vim/setup.vim')

require'kanagawa'.setup{
  undercurl = false,
  commentStyle = { italic = false },
  keywordStyle = { italic = false },
}
require'everforest'.setup{
  background = "hard",
  italics = false,
  ui_contrast = "high",
}

vim.cmd('colorscheme kanagawa')

require'mason'.setup()

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

  -- vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { desc = "Format buffer" })
  vim.keymap.set('n', '<leader>Rn', vim.lsp.buf.rename, { desc = 'Rename symbol under cursor' })
  vim.keymap.set('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
  vim.keymap.set('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
  vim.keymap.set('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
  vim.keymap.set('n','gre','<cmd>References<CR>')
  vim.keymap.set('n','gR','<cmd>lua vim.lsp.buf.references()<CR>')
  vim.keymap.set('n','[g','<cmd>lua vim.diagnostic.goto_prev()<CR>')
  vim.keymap.set('n',']g','<cmd>lua vim.diagnostic.goto_next()<CR>')
  vim.keymap.set('n','gk','<cmd>lua vim.diagnostic.open_float()<CR>')
end

-- Set up language servers
-- vim.lsp.set_log_level('debug') -- Include logs from attached language servers

vim.lsp.config('*', { on_attach = on_attach })

-- This could be improved, see:
-- ~/.local/share/nvim/plugged/nvim-lspconfig/lsp/clangd.lua
vim.lsp.config('clangd', { on_attach = on_attach })
vim.lsp.enable('clangd')

-- npm i -g bash-language-server
vim.lsp.config('bashls', {
  filetypes = { 'bash', 'zsh' },
})

vim.lsp.config('gopls', {
  -- see: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  settings = {
    gopls = {
      buildFlags = { "-mod=readonly" },
      semanticTokens = true,
    },
  },
})

-- brew install lua-language-server
vim.lsp.config('lua_ls', {
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
})
-- TODO: factor out enables?
vim.lsp.enable('lua_ls')

-- npm i -g vim-language-server
vim.lsp.config('vimls', {})

vim.lsp.config('ts_ls', {
  -- override attach function provided by lspconfig
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
})
vim.lsp.enable('ts_ls')

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "cpp", "typescript", "tsx", "lua", "vim", "vimdoc", "query" },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
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
    typescriptreact = { prettierd_format },
    ["*"] = {
      require('formatter.filetypes.any').remove_trailing_whitespace,
    },
  }
})

-- Load custom :References command to integrate fzf + lsp
require'fzf-lsp-references'
