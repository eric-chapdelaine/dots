return {
  {
    'echasnovski/mini.files',
    version = false,
    lazy = false,
    config = function()
      require('mini.files').setup({
        -- Customization of shown content
        content = {
          filter = nil,
          prefix = nil,
          sort = nil,
        },
        -- Module mappings created only inside explorer
        mappings = {
          close       = 'q',
          go_in       = 'l',
          go_in_plus  = 'L',
          go_out      = 'h',
          go_out_plus = 'H',
          reset       = '<BS>',
          reveal_cwd  = '@',
          show_help   = 'g?',
          synchronize = '=',
          trim_left   = '<',
          trim_right  = '>',
        },
        -- General options
        options = {
          permanent_delete = true,
          use_as_default_explorer = true,
        },
        -- Customization of explorer windows
        windows = {
          max_number = math.huge,
          preview = false,
          width_focus = 50,
          width_nofocus = 15,
          width_preview = 25,
        },
      })

      -- Keymap to toggle mini.files with backslash
      vim.keymap.set('n', '\\', function()
        if not MiniFiles.close() then
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        end
      end, { desc = 'Toggle mini.files' })
    end,
  },
}
