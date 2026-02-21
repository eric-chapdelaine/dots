-- Debug function for treesitter-context
local M = {}

function M.check_context()
  local ts_context = require('treesitter-context')
  
  print("=== Treesitter Context Debug ===")
  print("Enabled:", ts_context.enabled())
  
  -- Check if treesitter is working
  local has_parser = vim.treesitter.get_parser(0)
  print("Treesitter parser loaded:", has_parser ~= nil)
  
  if has_parser then
    print("Parser language:", has_parser:lang())
  end
  
  -- Check buffer filetype
  print("Buffer filetype:", vim.bo.filetype)
  
  -- Check window size
  local height = vim.api.nvim_win_get_height(0)
  print("Window height:", height)
  
  -- Check cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  print("Cursor position: line", cursor[1], "col", cursor[2])
  
  -- Try to get context
  local ok, context = pcall(require('treesitter-context.context').get, 0)
  if ok then
    print("Context data:", vim.inspect(context))
  else
    print("Error getting context:", context)
  end
  
  -- Check if context window exists
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("treesitter%-context") then
      print("Context window found:", win)
    end
  end
  
  print("================")
end

-- Create a command to call this
vim.api.nvim_create_user_command('DebugContext', M.check_context, {})

return M
