return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = nil,  -- Disable default <C-\> mapping
        hide_numbers = true,
        start_in_insert = true,
        persist_mode = true,
        close_on_exit = true,  -- Close when vim closes
        auto_scroll = true,
        direction = 'horizontal',  -- Default direction for terminal 1
        size = function(term)
          if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.3)  -- 30% of screen height
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)
          end
        end,
      })

      -- Terminal mode keymaps for easy navigation
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

      -- Terminal 1: Uses toggleterm's native horizontal split behavior
      -- Always force horizontal direction and 30% height
      vim.keymap.set("n", "<leader>tt", function()
        vim.cmd("1ToggleTerm direction=horizontal")
      end, { desc = "Toggle Terminal 1 (split)" })
      
      vim.keymap.set("t", "<leader>tt", function()
        vim.cmd("1ToggleTerm direction=horizontal")
      end, { desc = "Toggle Terminal 1 (split)" })

      -- Terminals 2-4: Custom implementation for buffer replacement
      -- Track previous buffers for each terminal
      local terminal_previous_buffers = {}

      local function toggle_terminal_buffer(term_id)
        local Terminal = require('toggleterm.terminal').Terminal
        local terminals = require("toggleterm.terminal").get_all(true)
        
        -- Find the terminal with this ID
        local term = nil
        for _, t in pairs(terminals) do
          if t.id == term_id then
            term = t
            break
          end
        end
        
        -- If terminal doesn't exist, create it
        if not term then
          term = Terminal:new({
            count = term_id,
            hidden = true,  -- Don't show in normal toggleterm commands
            direction = 'horizontal',  -- Doesn't matter, we're handling display manually
          })
          term:spawn()
        end
        
        local current_buf = vim.api.nvim_get_current_buf()
        local term_buf = term.bufnr
        
        -- If we're currently in the terminal buffer, switch back to previous
        if current_buf == term_buf then
          local prev_buf = terminal_previous_buffers[term_id]
          if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
            vim.api.nvim_set_current_buf(prev_buf)
          else
            -- If no valid previous buffer, create a new one
            vim.cmd('enew')
          end
        else
          -- Save current buffer and switch to terminal
          terminal_previous_buffers[term_id] = current_buf
          vim.api.nvim_set_current_buf(term_buf)
          vim.cmd('startinsert')
        end
      end

      vim.keymap.set("n", "<leader>t2", function() toggle_terminal_buffer(2) end, { desc = "Toggle Terminal 2 (replace)" })
      vim.keymap.set("n", "<leader>t3", function() toggle_terminal_buffer(3) end, { desc = "Toggle Terminal 3 (replace)" })
      vim.keymap.set("n", "<leader>t4", function() toggle_terminal_buffer(4) end, { desc = "Toggle Terminal 4 (replace)" })
      
      vim.keymap.set("t", "<leader>t2", function() toggle_terminal_buffer(2) end, { desc = "Toggle Terminal 2 (replace)" })
      vim.keymap.set("t", "<leader>t3", function() toggle_terminal_buffer(3) end, { desc = "Toggle Terminal 3 (replace)" })
      vim.keymap.set("t", "<leader>t4", function() toggle_terminal_buffer(4) end, { desc = "Toggle Terminal 4 (replace)" })
    end,
  },
}
