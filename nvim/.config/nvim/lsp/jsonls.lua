return {
  on_attach = function(client, bufnr)
    -- Check if there's a sibling schema file
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    if buf_name == '' or not buf_name:match('%.json$') then
      return
    end

    local schema_path = buf_name:gsub('%.json$', '.schema.json')

    -- If schema file exists, associate it with this file
    if vim.fn.filereadable(schema_path) == 1 then
      local schema_url = 'file://' .. schema_path

      -- Update the workspace configuration to associate this file with its schema
      client.config.settings.json.schemas = client.config.settings.json.schemas or {}
      table.insert(client.config.settings.json.schemas, {
        fileMatch = { buf_name },
        url = schema_url,
      })

      -- Notify the server of the updated settings
      client.notify('workspace/didChangeConfiguration', {
        settings = client.config.settings,
      })
    end
  end,
  settings = {
    json = {
      validate = { enable = true },
    },
  },
}
