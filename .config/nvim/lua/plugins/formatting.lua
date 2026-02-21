return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    opts = {
      -- Define formatters by filetype
      formatters_by_ft = {
        -- TypeScript/JavaScript - use prettier from project
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        
        -- Other web formats
        json = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        scss = { 'prettierd', 'prettier', stop_after_first = true },
        
        -- PHP - use ***REDACTED*** (***REDACTED***) for WFE, fall back to php-cs-fixer
        php = { '***REDACTED***', 'php_cs_fixer', stop_after_first = true },
        
        -- Lua
        lua = { 'stylua' },
      },
      
      -- Format on save
      format_on_save = function(bufnr)
        -- Check if formatting is disabled globally or for this buffer
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        
        -- Disable format on save for certain filetypes
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        
        return {
          timeout_ms = 1000,
          lsp_fallback = true,
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
      },
    },
  },
}
