-- Autocommands

local function get_prettier_tab_width(buffer)
  local file_path = vim.api.nvim_buf_get_name(buffer)
  local config_path = vim.fs.find({ '.prettierrc', '.prettierrc.json' }, {
    upward = true,
    path = vim.fs.dirname(file_path),
  })[1]

  if not config_path then
    return
  end

  local config_file = io.open(config_path, 'r')
  if not config_file then
    return
  end

  local config_content = config_file:read('*a')
  config_file:close()

  local decoded, config = pcall(vim.json.decode, config_content)
  if decoded and type(config) == 'table' and type(config.tabWidth) == 'number' then
    return config.tabWidth
  end
end

-- Match JS/TS indentation to the nearest project's Prettier configuration.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Set JS/TS indentation from the project Prettier config',
  group = vim.api.nvim_create_augroup('js-ts-indent', { clear = true }),
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function(event)
    local tab_width = get_prettier_tab_width(event.buf)
    if not tab_width then
      return
    end

    vim.bo[event.buf].shiftwidth = tab_width
    vim.bo[event.buf].tabstop = tab_width
    vim.bo[event.buf].softtabstop = tab_width
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
