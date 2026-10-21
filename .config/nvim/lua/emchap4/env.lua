-- Environment setup for Neovim
-- Ensure node/npm and local CLI tools are in PATH

local function prepend_path(dir)
  if dir == "" or vim.fn.isdirectory(dir) == 0 then
    return
  end

  local current_path = vim.env.PATH or ""
  if not string.find(current_path, dir, 1, true) then
    vim.env.PATH = dir .. ":" .. current_path
  end
end

local function setup_local_bin_path()
  prepend_path(vim.fn.expand("~/.local/bin"))
end

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

setup_local_bin_path()
setup_node_path()
