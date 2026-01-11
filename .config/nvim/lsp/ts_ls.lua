return {
  on_init = function(client)
    -- Disable LSP's syntax highlighting
    client.server_capabilities.semanticTokensProvider = nil
    -- Disable formatting to avoid conflict with prettier
    client.server_capabilities.documentFormattingProvider = false
    -- no `implementationProvider` responses from this LSP to avoid conflicting with css modules
    -- (use definition instead)
    -- client.server_capabilities.implementationProvider = false
  end,
  settings = {
    -- 80001: "File is a CommonJS module..."
    -- diagnostics = { ignoredCodes = { 80001 } },
  },
  -- See https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
  init_options = {
    hostInfo = 'neovim',
    maxTsServerMemory = 10240,
    typescript = {
      tsdk = "node_modules/typescript/lib",
      enablePromptUseWorkspaceTsdk = true,
    },
  },
}
