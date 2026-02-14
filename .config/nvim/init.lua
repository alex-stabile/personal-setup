local function install_plugins()
  local Plug = vim.fn['plug#']
  vim.call('plug#begin')
  Plug('mason-org/mason.nvim')
  Plug('neovim/nvim-lspconfig')
  Plug('nvim-treesitter/nvim-treesitter', { ['branch'] = 'master', ['build'] = ':TSUpdate' })

  Plug('stevearc/conform.nvim')
  Plug('mfussenegger/nvim-lint')

  Plug('junegunn/fzf')
  Plug('junegunn/fzf.vim')

  Plug('lewis6991/gitsigns.nvim')

  Plug('tpope/vim-fugitive')
  Plug('tpope/vim-rhubarb')

  Plug('neanias/everforest-nvim', { ['branch'] = 'main' })
  Plug('rebelot/kanagawa.nvim')
  Plug('catppuccin/nvim', { ['as'] = 'catppuccin' })
  vim.call('plug#end')
end
install_plugins()

vim.o.termguicolors = true
vim.o.background = 'dark'
-- float window style
vim.o.winborder = 'bold'
-- everything else
vim.cmd('source ' .. vim.fn.expand('<sfile>:p:h') .. '/../../.vim/setup.vim')

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

  vim.keymap.set('n','<leader>Rn', vim.lsp.buf.rename, { desc = 'Rename symbol under cursor' })
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
vim.lsp.enable('jsonls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('ruby_lsp')
vim.lsp.enable('sorbet')
vim.lsp.enable('ts_ls')
vim.lsp.enable('vimls')
vim.lsp.enable('yamlls')

-- Load custom :References command to integrate fzf + lsp
require'fzf-lsp-references'

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "cpp", "typescript", "tsx", "lua", "vim", "vimdoc", "query", "yaml" },
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

vim.env.ESLINT_D_PPID = vim.fn.getpid()
require('lint').linters_by_ft = {
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  javascriptreact = { "eslint_d" },
}
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  -- Note this autocmd is javascript-specific for the cwd handling
  pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' , '*.mjs', '*.cjs' },
  callback = function()
    -- arg0: the linter to use, nil to infer from filetype
    -- arg1.cwd: nvim-lint does no magic to determine the cwd for the command, and will
    --  use the vim session's cwd by default, so we need to pass our own in a monorepo.
    --  This expr means: for the current buffer, find the first parent dir containing config file
    require('lint').try_lint(nil, { cwd = vim.fs.root(0, { 'eslint.config.mjs', 'package.json' }) })
  end,
})
vim.api.nvim_create_user_command('ESLint', function()
  -- nvim-lint has a bug: it prints the cd operations when it changes to handle the passed cwd,
  -- so this is a workaround to silence it
  vim.cmd('silent! lua require("lint").try_lint("eslint_d", { cwd = vim.fs.root(0, { "eslint.config.mjs", "package.json" }) })')
end, { desc = 'Run eslint_d' })

require'conform'.setup {
  formatters_by_ft = {
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    javascriptreact = { "prettierd" },
    css = { "prettierd" },
    ruby = { "prettierd" },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = false,
  },
}
vim.api.nvim_create_user_command('Format', function()
  require('conform').format({ lsp_fallback = false, timeout_ms = 1000 })
end, { desc = 'Use eslint_d to run eslint --fix' })
vim.api.nvim_create_user_command('ESLintFix', function()
  require('conform').format({ formatters = { 'eslint_d' }, timeout_ms = 5000 })
end, { desc = 'Use eslint_d to run eslint --fix' })

require'gitsigns'.setup {
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Leader actions
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)
    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)
    map('n', '<leader>hB', gitsigns.blame)
    map('n', '<leader>hd', gitsigns.diffthis)
    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)
  end
}

