-- Creates a user command :References, similar to coc-references.
-- Gets references to the symbol under the cursor from LSP,
-- and parse/preview them with FZF, similar to fzf.vim package.

local function fzf_run(opts)
  vim.fn['fzf#run'](vim.fn['fzf#wrap'](opts))
end

local function str_from_loc(loc, include_filename)
  return vim.fn.fnamemodify(loc['filename'], ':p:~:.')
    .. ":"
    .. loc["lnum"]
    .. ":"
    .. loc["col"]
    .. ": "
    .. vim.trim(loc["text"])
end

local cmd_by_key =
{
  [''] = 'edit',
  ['ctrl-t'] = 'tabedit',
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit',
}

local function handle_sinklist(e)
  local key = e[1]
  -- extract from line like "src/myfile.ts:<row>:<col>:<contents>
  local path, lnum, _col = e[2]:match("([^:]*):([^:]*):([^:]*):")
  -- execute e.g. ":edit src/myfile", but silently
  vim.cmd(vim.fn.printf('silent keepalt exec "%s +%d %s"', cmd_by_key[key] or 'e', lnum, path))
end

local function on_list(options)
  vim.notify('Got '..table.getn(options.items)..' locations')
  local items = options.items
  local str = str_from_loc(items[1])

  local list = {}
  for _, loc in ipairs(items) do
    table.insert(list, str_from_loc(loc))
  end
  local preview_cmd = 'bat --color=always --theme=gruvbox-dark --style=header,grid {1} --highlight-line {2}'
  fzf_run({
    sinklist = handle_sinklist,
    source = list,
    window = { width = 0.9, height = 0.8 },
    options = vim.fn.printf('--layout=reverse --expect=ctrl-t,ctrl-x,ctrl-v --info=inline --delimiter : --preview "%s" --preview-window "+{2}-5"', preview_cmd),
  })
end

local function fzf_references()
  vim.notify('Requesting references...')
  vim.lsp.buf.references(nil, {on_list = on_list})
end

vim.api.nvim_create_user_command('References', fzf_references, {})
