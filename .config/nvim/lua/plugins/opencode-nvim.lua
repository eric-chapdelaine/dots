return {
  {
    'nickjvandyke/opencode.nvim',
    version = '*', -- Latest stable release
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      -- Configuration via global variable
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Provider configuration
        provider = {
          enabled = 'terminal', -- Uses Neovim's built-in terminal
        },
        
        -- Optional: customize prompts, contexts, etc.
        -- See :h opencode-config for all options
      }

      -- Enable auto-reload for opencode edits
      vim.o.autoread = true

      -- Keybindings for OpenCode
      -- Main ask/prompt (works in normal and visual mode)
      vim.keymap.set({ 'n', 'x' }, '<leader>oa', function()
        require('opencode').ask('@this: ', { submit = true })
      end, { desc = '[O]penCode: [A]sk…' })

      -- Select from all opencode functionality
      vim.keymap.set({ 'n', 'x' }, '<leader>ox', function()
        require('opencode').select()
      end, { desc = '[O]penCode: E[x]ecute action…' })

      -- Toggle opencode terminal
      vim.keymap.set({ 'n', 't' }, '<leader>ot', function()
        require('opencode').toggle()
      end, { desc = '[O]penCode: [T]oggle terminal' })

      -- Operator to add range to opencode
      vim.keymap.set({ 'n', 'x' }, '<leader>oo', function()
        return require('opencode').operator('@this ')
      end, { desc = '[O]penCode: [O]perator (add range)', expr = true })

      -- Add current line to opencode
      vim.keymap.set('n', '<leader>ol', function()
        return require('opencode').operator('@this ') .. '_'
      end, { desc = '[O]penCode: Add [L]ine', expr = true })

      -- Quick prompts
      vim.keymap.set({ 'n', 'x' }, '<leader>oe', function()
        require('opencode').prompt('explain', { submit = true })
      end, { desc = '[O]penCode: [E]xplain' })

      vim.keymap.set({ 'n', 'x' }, '<leader>or', function()
        require('opencode').prompt('review', { submit = true })
      end, { desc = '[O]penCode: [R]eview' })

      vim.keymap.set({ 'n', 'x' }, '<leader>of', function()
        require('opencode').prompt('fix', { submit = true })
      end, { desc = '[O]penCode: [F]ix' })

      vim.keymap.set({ 'n', 'x' }, '<leader>od', function()
        require('opencode').prompt('document', { submit = true })
      end, { desc = '[O]penCode: [D]ocument' })

      -- Session management
      vim.keymap.set('n', '<leader>os', function()
        require('opencode').select_session()
      end, { desc = '[O]penCode: Select [S]ession' })

      vim.keymap.set('n', '<leader>oc', function()
        require('opencode').command('session.new')
      end, { desc = '[O]penCode: New session ([C]lear)' })
    end,
  },
}
