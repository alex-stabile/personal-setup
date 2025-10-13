local function install_plugins()
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
-- everything else
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

local function on_attach(args)
  local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
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
vim.api.nvim_create_autocmd('LspAttach', { callback = on_attach })

-- LSP setup
-- nvim-lspconfig defaults in:
-- ~/.local/share/nvim/plugged/nvim-lspconfig/lsp/<name>.lua
-- my configs in ./lsp/<name>.lua
vim.lsp.enable('bashls')
vim.lsp.enable('clangd')
vim.lsp.enable('gopls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('ts_ls')
vim.lsp.enable('vimls')

-- Load custom :References command to integrate fzf + lsp
require'fzf-lsp-references'

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
