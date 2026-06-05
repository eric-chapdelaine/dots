return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local treesitter = require('nvim-treesitter')

      -- Parsers for Nile-Core (Ruby/Rails, YAML, ERB) and NileWebApps (TS/TSX, CSS, JSON).
      local preferred_parsers = {
        'bash',
        'c',
        'css',
        'diff',
        'dockerfile',
        'embedded_template',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'ruby',
        'sql',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      }

      local installed = treesitter.get_installed()
      local missing = vim.tbl_filter(function(language)
        return not vim.tbl_contains(installed, language)
      end, preferred_parsers)

      if #missing > 0 then
        treesitter.install(missing, { summary = false }):wait(300000)
      end

      local indent_disabled = { 'ruby', 'typescript', 'javascript', 'tsx', 'jsx' }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('emchap4-treesitter', { clear = true }),
        callback = function(event)
          local filetype = event.match
          local language = vim.treesitter.language.get_lang(filetype)

          if not language then
            pcall(function()
              treesitter.install({ filetype }, { summary = false }):wait(10000)
              language = vim.treesitter.language.get_lang(filetype)
            end)
          end

          if not language then
            return
          end

          pcall(vim.treesitter.start, event.buf, language)

          if not vim.tbl_contains(indent_disabled, filetype) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
