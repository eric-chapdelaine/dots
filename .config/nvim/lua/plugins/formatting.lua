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
        
        -- PHP - use ECS (Easy Coding Standard) for WFE, fall back to php-cs-fixer
        php = { 'ecs', 'php_cs_fixer', stop_after_first = true },
        
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
        
        -- ECS (Easy Coding Standard) for WFE
        ecs = {
          command = function()
            -- Try to find vendor/bin/ecs in the project root
            local root = vim.fs.dirname(vim.fs.find({ 
              'ecs.php',
              'composer.json',
            }, { upward = true })[1])
            
            if root then
              local ecs_path = root .. '/vendor/bin/ecs'
              if vim.fn.executable(ecs_path) == 1 then
                return ecs_path
              end
            end
            
            -- Fall back to global ecs if available
            return 'ecs'
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
