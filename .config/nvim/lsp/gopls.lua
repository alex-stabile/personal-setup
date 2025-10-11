return {
  -- see: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  settings = {
    gopls = {
      buildFlags = { "-mod=readonly" },
      semanticTokens = true,
    },
  },
}
