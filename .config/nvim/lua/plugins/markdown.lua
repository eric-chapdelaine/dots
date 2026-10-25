-- Markdown rendering, tuned for ONE goal: the text on screen should stay put.
--
-- Layout stability rules followed throughout this file:
--   1. `anti_conceal = false` — the single most important setting. Without it,
--      every concealed element on the cursor line un-conceals as you move the
--      cursor, so the line's text jumps left/right row by row. With it off,
--      what you see is a pure function of the buffer, not of the cursor.
--   2. No *inline* virt_text. Inline marks insert cells and push real text to
--      the right, so the same line sits at a different column depending on
--      how much decoration precedes it. Icons are therefore all removed
--      (headings, links, code language labels, checkboxes).
--   3. No character concealing anywhere, with one deliberate exception: table
--      pipes and cell padding. Concealing `#`, `[x]`, code fences, link
--      brackets and HTML comments makes text disappear and reappear; that is
--      exactly the churn being avoided. This includes Neovim's *runtime*
--      markdown queries, which conceal delimiters on their own — see
--      `strip_conceal_blockers` at the bottom of this file.
--   4. No virt_lines (heading borders, code borders, table top/bottom rules).
--      They do not shift columns, but they insert screen rows, which makes
--      scrolling and `j`/`k` targets feel wrong.
--
-- What is left is decoration that changes *colour and same-width glyphs in
-- place*: heading foreground/background, code block background, `-` → `●`,
-- `>` → `▋`, `---` → `─`, and table column alignment.
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "octo" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>tm",
        function()
          require("render-markdown").buf_toggle()
        end,
        desc = "Toggle markdown rendering (buffer)",
      },
      {
        "<leader>tM",
        function()
          require("render-markdown").toggle()
        end,
        desc = "Toggle markdown rendering (global)",
      },
    },
    opts = {
      -- Render in every mode you actually sit in. Anything not listed here
      -- switches the whole buffer back to raw on entering that mode, which is
      -- a full-buffer relayout — the worst-case version of the thing we are
      -- trying to avoid. 't' is omitted: terminal buffers are not markdown.
      render_modes = { "n", "i", "v", "c" },

      file_types = { "markdown", "octo", "gitcommit" },
      nested = false,

      -- THE key setting: nothing un-renders when the cursor moves.
      anti_conceal = { enabled = false },

      -- Sign column: signs can push every line right by 2 cells when the
      -- column appears. Nothing here needs one.
      sign = { enabled = false },

      heading = {
        enabled = true,
        -- Empty icon list => no icon is drawn and therefore nothing is
        -- concealed. The `#`s stay exactly where they are.
        icons = {},
        sign = false,
        -- Borders are virt_lines: they add screen rows. Off.
        border = false,
        above = "",
        below = "",
        width = "block",
        left_margin = 0,
        left_pad = 0,
        right_pad = 0,
        min_width = 0,
      },

      code = {
        enabled = true,
        sign = false,
        -- Keep the ``` fence lines visible instead of hiding them.
        conceal_delimiters = false,
        -- No "󰈙 lua" label overlaid on the fence line.
        language = false,
        language_icon = false,
        language_name = false,
        language_info = false,
        -- 'none' => no ▀/▄ rows added above/below the block.
        border = "none",
        -- No grey slab behind fenced code blocks. Syntax highlighting already
        -- separates code from prose; the slab was only adding a colour that
        -- reads badly against the rest of the colorscheme. `true` disables it
        -- for every language (the default is just { 'diff' }).
        disable_background = true,
        -- No background behind `inline code` either, and no space trimming
        -- inside the backticks.
        inline = false,
      },

      -- Checkboxes conceal `[ ]` and insert an icon, moving the item text.
      -- Left raw.
      checkbox = { enabled = false },

      -- Bullets stay as the literal `-` / `*` you typed. Swapping them for
      -- `●` is a same-width substitution, but it still replaces the characters
      -- you read and grep for.
      bullet = { enabled = false },

      quote = { enabled = true, icon = "▋" },

      -- `---` stays three dashes instead of becoming a full-width rule.
      dash = { enabled = false },

      -- Every link decoration is an *inline* icon placed before the link
      -- text, which pushes the text right. Empty-string icons fall back to
      -- the built-in glyphs, so the renderer has to be turned off outright.
      link = { enabled = false },

      -- HTML comments used to be concealed; keep them visible.
      html = { enabled = true, comment = { conceal = false } },

      -- Both conceal their markers (==foo== -> foo, $x$ -> rendered).
      inline_highlight = { enabled = false },
      latex = { enabled = false },

      -- YAML frontmatter: only ever did bullet overlays and wiki links.
      yaml = { enabled = false },

      -- Org-style indentation shifts every line under a heading.
      indent = { enabled = false },

      -- THE exception. Tables are unreadable without column alignment, so
      -- pipes are redrawn as │ and cells are padded to a common width.
      --
      --   cell = 'padded'  -> pads cells per column, so rows line up
      --                       (this is the bit that actually makes tables
      --                       readable; 'overlay' would do no alignment)
      --   wrap   = false   -> don't reflow cells into extra rows when the
      --                       window is narrow; wrapping depends on window
      --                       width and rewrites rows wholesale
      --   border_enabled = false -> no ┌───┐/└───┘ virt_lines above and below
      --                       (they add screen rows); the ├───┼───┤ rule
      --                       under the header is always drawn and is enough
      --
      -- With anti_conceal off, the padded alignment now holds on the cursor
      -- row too, instead of snapping back to raw `| a | b |` when you enter
      -- the table. That was the all-or-nothing behaviour being complained
      -- about.
      pipe_table = {
        enabled = true,
        cell = "padded",
        wrap = false,
        padding = 1,
        min_width = 0,
        border_enabled = false,
        style = "normal",
        -- Same glyph as the rest of the rule, so the header separator is one
        -- clean line instead of `┼━───━┼` mixed-weight segments.
        alignment_indicator = "─",
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- Neovim ships markdown highlight queries that conceal syntax on their
      -- own, independently of render-markdown:
      --
      --   queries/markdown/highlights.scm
      --     (fenced_code_block (fenced_code_block_delimiter) @markup.raw.block
      --        (#set! conceal "") (#set! conceal_lines ""))
      --     (fenced_code_block (info_string (language) @label
      --        (#set! conceal "") (#set! conceal_lines "")))
      --   queries/markdown_inline/highlights.scm
      --     [(code_span_delimiter) (emphasis_delimiter)] @conceal
      --        (#set! conceal "")
      --     (inline_link ["[" "]" "(" (link_destination) ")"] @markup.link
      --        (#set! conceal ""))
      --
      -- Those fire whenever 'conceallevel' > 0. render-markdown raises it to 3
      -- while rendering, because its table alignment genuinely needs conceal
      -- (lua/render-markdown/render/markdown/table.lua: "without concealing it
      -- is impossible to do full alignment"). So the level cannot simply be
      -- dropped, and the conceal directives have to be removed from the query
      -- instead.
      --
      -- Stripping `(#set! conceal ...)` leaves the capture groups in place, so
      -- highlighting is unchanged — only the hiding stops. `conceal_lines` is
      -- stripped too; it hides whole fence lines.
      local function strip_conceal(lang)
        local files = vim.api.nvim_get_runtime_file("queries/" .. lang .. "/highlights.scm", true)
        if #files == 0 then
          return
        end
        local parts = {}
        for _, file in ipairs(files) do
          parts[#parts + 1] = table.concat(vim.fn.readfile(file), "\n")
        end
        local query = table.concat(parts, "\n")
        local stripped
        query, stripped = query:gsub('%(%s*#set!%s+conceal[a-z_]*%s+"[^"]*"%s*%)', "")
        if stripped == 0 then
          return
        end
        local ok, err = pcall(vim.treesitter.query.set, lang, "highlights", query)
        if not ok then
          vim.notify("markdown: failed to strip conceal from " .. lang .. " query: " .. tostring(err), vim.log.levels.WARN)
        end
      end

      strip_conceal("markdown")
      strip_conceal("markdown_inline")

      -- The query cache is populated lazily per language; if neovim already
      -- parsed a markdown buffer before this ran, the old query is cached.
      -- Re-setting on FileType keeps non-markdown startup cheap and makes the
      -- override survive `:InspectTree` / first-open ordering.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("render-markdown-strip-conceal", { clear = true }),
        pattern = { "markdown", "octo", "gitcommit" },
        callback = function()
          strip_conceal("markdown")
          strip_conceal("markdown_inline")
        end,
      })
    end,
  },
}
