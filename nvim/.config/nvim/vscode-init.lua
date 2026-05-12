-- Custom entrypoint for use with the VSCode Neovim extension,
-- set with: vscode-neovim.neovimInitVimPaths.darwin
local function test()
  vim.notify('Testing testing testinggggg')
end
vim.api.nvim_create_user_command('NvimTestVscode', test, {})

vim.cmd('source ' .. vim.fn.expand('<sfile>:p:h') .. '/../../.vim/setup.vim')

-- to fix fold behavior (add to vscode-neovim.afterInitConfig, doesn't work here)
-- see: https://vimhelp.org/motion.txt.html#gj
-- nmap k gk
-- nmap j gj

vim.keymap.set('n', 'gR', function()
  require('vscode').call('editor.action.referenceSearch.trigger')
end)
vim.keymap.set('n', 'za', function()
  require('vscode').call('editor.toggleFold')
end)
