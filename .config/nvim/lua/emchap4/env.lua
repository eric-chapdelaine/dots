-- Environment setup for Neovim
-- Ensure node/npm are in PATH for formatters and LSP

local function setup_node_path()
  -- Get the nvm directory
  local nvm_dir = os.getenv('HOME') .. '/.nvm'
  
  -- Find the default node version or current version
  local default_node = os.getenv('HOME') .. '/.nvm/versions/node/v18.20.4'
  
  -- Check if the default node exists
  local handle = io.open(default_node .. '/bin/node', 'r')
  if handle then
    handle:close()
    -- Add to PATH
    local current_path = vim.env.PATH
    local node_bin = default_node .. '/bin'
    
    -- Only add if not already in PATH
    if not string.find(current_path, node_bin, 1, true) then
      vim.env.PATH = node_bin .. ':' .. current_path
    end
  end
end

-- Call the setup function
setup_node_path()
