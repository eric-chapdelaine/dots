return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_format = 'never' })
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      -- Define formatters by filetype
      formatters_by_ft = {
        -- TypeScript/JavaScript - use prettier from project
        typescript = { 'prettier', 'prettierd', stop_after_first = true },
        typescriptreact = { 'prettier', 'prettierd', stop_after_first = true },
        javascript = { 'prettier', 'prettierd', stop_after_first = true },
        javascriptreact = { 'prettier', 'prettierd', stop_after_first = true },
        
        -- Other web formats
        json = { 'prettier', 'prettierd', stop_after_first = true },
        yaml = { 'prettier', 'prettierd', stop_after_first = true },
        markdown = { 'prettier', 'prettierd', stop_after_first = true },
        html = { 'prettier', 'prettierd', stop_after_first = true },
        css = { 'prettier', 'prettierd', stop_after_first = true },
        scss = { 'prettier', 'prettierd', stop_after_first = true },
        
        -- PHP - php-cs-fixer
        php = { 'php_cs_fixer', stop_after_first = true },
        
        -- Lua
        lua = { 'stylua' },

      },
      
      -- Format on save
      format_on_save = function(bufnr)
        -- Check if formatting is disabled globally or for this buffer
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end

        local ft = vim.bo[bufnr].filetype
        if ft == 'c' or ft == 'cpp' or ft == 'markdown' or ft:find('yaml', 1, true) then
          return
        end

        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match('%.ya?ml$') or bufname:match('%.md$') then
          return
        end

        return {
          timeout_ms = 1000,
          lsp_format = 'never',
        }
      end,
      
      -- Customize formatters
      formatters = {
        -- Prettier will automatically find .prettierrc in project root
        prettier = {},
        -- Prettierd is faster but needs to be installed separately
        prettierd = {},
        
        
        php_cs_fixer = {
          command = 'php-cs-fixer',
          args = {
            'fix',
            '$FILENAME',
            '--rules=@PSR12',
          },
          stdin = false,
        },

      },
    },
  },
}
