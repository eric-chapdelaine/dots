return {
  {
    'dnlhc/glance.nvim',
    event = 'LspAttach',
    config = function()
      local glance = require('glance')
      local actions = glance.actions

      glance.setup({
        height = 18, -- Height of the window
        zindex = 45,
        
        -- Preview window offset from top and bottom of the editor
        preview_win_opts = {
          cursorline = true,
          number = true,
          wrap = true,
        },
        
        -- List window offset from top and bottom of the editor
        list_win_opts = {
          cursorline = true,
          number = false,
          wrap = false,
        },
        
        theme = { -- Apply custom highlights
          enable = true,
          mode = 'auto', -- 'brighten' or 'darken' or 'auto'
        },
        
        mappings = {
          list = {
            ['j'] = actions.next, -- Move to next item
            ['k'] = actions.previous, -- Move to previous item
            ['<Down>'] = actions.next,
            ['<Up>'] = actions.previous,
            ['<Tab>'] = actions.next_location, -- Move to next location (file)
            ['<S-Tab>'] = actions.previous_location, -- Move to previous location (file)
            ['<C-u>'] = actions.preview_scroll_win(5),
            ['<C-d>'] = actions.preview_scroll_win(-5),
            ['v'] = actions.jump_vsplit, -- Jump to vsplit
            ['s'] = actions.jump_split, -- Jump to split
            ['t'] = actions.jump_tab, -- Jump to tab
            ['<CR>'] = actions.jump, -- Jump to location
            ['o'] = actions.jump,
            ['<leader>l'] = actions.enter_win('preview'), -- Focus preview window
            ['q'] = actions.close, -- Close glance window
            ['Q'] = actions.close,
            ['<Esc>'] = actions.close,
          },
          preview = {
            ['Q'] = actions.close,
            ['<Tab>'] = actions.next_location,
            ['<S-Tab>'] = actions.previous_location,
            ['<leader>l'] = actions.enter_win('list'), -- Focus list window
          },
        },
        
        hooks = {},
        folds = {
          fold_closed = '',
          fold_open = '',
          folded = true, -- Automatically fold list on startup
        },
        
        indent_lines = {
          enable = true,
          icon = '│',
        },
        
        winbar = {
          enable = true, -- Show window bar with file path
        },
      })

      -- Keybindings for glance
      vim.keymap.set('n', 'gpd', '<cmd>Glance definitions<CR>', { desc = '[G]lance [P]eek [D]efinitions' })
      vim.keymap.set('n', 'gpr', '<cmd>Glance references<CR>', { desc = '[G]lance [P]eek [R]eferences' })
      vim.keymap.set('n', 'gpt', '<cmd>Glance type_definitions<CR>', { desc = '[G]lance [P]eek [T]ype definitions' })
      vim.keymap.set('n', 'gpi', '<cmd>Glance implementations<CR>', { desc = '[G]lance [P]eek [I]mplementations' })
    end,
  },
}
