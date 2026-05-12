-- Standalone script to declare plugins so they can be installed headlessly:
-- `nvim --headless -u <this file> +PlugInstall +qall`
local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('mason-org/mason.nvim')
Plug('neovim/nvim-lspconfig')
Plug('nvim-treesitter/nvim-treesitter', { ['branch'] = 'master', ['build'] = ':TSUpdate' })

Plug('github/copilot.vim')

-- use a release tag to download pre-built binaries.
Plug('saghen/blink.cmp', { ['tag'] = 'v1.*' })

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
