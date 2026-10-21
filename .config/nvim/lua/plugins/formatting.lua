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
        
        -- PHP - use ***REDACTED*** (***REDACTED***) for WFE, fall back to php-cs-fixer
        php = { '***REDACTED***', 'php_cs_fixer', stop_after_first = true },
        
        -- Lua
        lua = { 'stylua' },

        -- ***REDACTED*** / ***REDACTED*** (***REDACTED*** via bundle)
        ***REDACTED*** = { '***REDACTED***', lsp_format = false },
        ***REDACTED*** = { '***REDACTED***', lsp_format = false },
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
        
        -- ***REDACTED*** (***REDACTED***) for WFE
        ***REDACTED*** = {
          command = function()
            -- Try to find vendor/bin/***REDACTED*** in the project root
            local root = vim.fs.dirname(vim.fs.find({ 
              '***REDACTED***',
              'composer.json',
            }, { upward = true })[1])
            
            if root then
              local ***REDACTED*** = root .. '/vendor/bin/***REDACTED***'
              if vim.fn.executable(***REDACTED***) == 1 then
                return ***REDACTED***
              end
            end
            
            -- Fall back to global ***REDACTED*** if available
            return '***REDACTED***'
          end,
          args = { 'check', '--fix', '$FILENAME' },
          stdin = false,
        },
        
        php_cs_fixer = {
          command = 'php-cs-fixer',
          args = {
            'fix',
            '$FILENAME',
            '--rules=@PSR12',
          },
          stdin = false,
        },

        ***REDACTED*** = {
          command = function()
            local root = vim.fs.dirname(vim.fs.find({
              '***REDACTED***',
              '.***REDACTED***.yml',
            }, { upward = true })[1])

            if root then
              local ***REDACTED*** = root .. '/bin/***REDACTED***'
              if vim.fn.executable(***REDACTED***) == 1 then
                return ***REDACTED***
              end
            end

            return '***REDACTED***'
          end,
          args = { '--autocorrect', '--stderr', '--stdout', '--display-cop-names', '--extra-details', '--format', 'simple', '$FILENAME' },
          stdin = false,
        },
      },
    },
  },
}
