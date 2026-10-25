-- GitHub PRs / issues / review threads inside Neovim, via the `gh` CLI.
--
-- Local git stays fugitive's job (see git.lua). Octo is the *remote* half:
-- picking PRs, reading descriptions, and doing split-view code review with
-- inline comments and suggestions that post back as a real review.
--
-- Auth: uses whatever `gh auth` already has. Verify with `gh auth status`.
return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>op", "<CMD>Octo pr list<CR>", desc = "GitHub: list pull requests" },
      { "<leader>oi", "<CMD>Octo issue list<CR>", desc = "GitHub: list issues" },
      { "<leader>on", "<CMD>Octo notification list<CR>", desc = "GitHub: notifications" },
      { "<leader>os", "<CMD>Octo search<CR>", desc = "GitHub: search" },
      { "<leader>or", "<CMD>Octo review start<CR>", desc = "GitHub: review current branch" },
      {
        "<leader>oR",
        function()
          -- Resume a review left pending (e.g. from the web UI or a prior session).
          local ok = pcall(vim.cmd, "Octo review resume")
          if not ok then
            vim.notify("No pending review to resume", vim.log.levels.WARN)
          end
        end,
        desc = "GitHub: resume pending review",
      },
      { "<leader>oc", "<CMD>Octo pr checkout<CR>", desc = "GitHub: checkout PR branch" },
      { "<leader>ob", "<CMD>Octo<CR>", desc = "GitHub: builtin command picker" },
    },
    opts = {
      picker = "telescope",

      -- Bare `Octo` opens a picker of every builtin action.
      enable_builtin = true,

      -- false = diffs come from the GitHub API into scratch buffers. Your
      -- worktree is never touched mid-review, so LSP/hover don't fight a
      -- half-checked-out branch. Set true only if you want `gf` into real
      -- files at the cost of switching the working tree to the PR commit.
      use_local_fs = false,

      -- GHES support is per-PR via `octo://<host>/owner/repo/pull/123`.
      github_hostname = "",

      -- Octo sets conceallevel itself; 2 keeps one char of concealed syntax
      -- visible, which reads better than 0 in a mixed prose/code buffer.
      -- render-markdown.nvim overrides this to 3 while it is rendering.
      ui = {
        conceallevel = 2,
        use_statuscolumn = true,
        use_foldtext = true,
        fold_checks = true,
      },

      reviews = {
        -- Pop the thread buffer when the cursor lands on a commented line.
        auto_show_threads = true,
        focus = "right",
        show_virtual_text = true,
      },

      -- Suggested multi-line comments already get `snippet_context_lines`
      -- lines of context; 4 matches GitHub's own default.
      snippet_context_lines = 4,

      -- Octo shells out to `gh`; keep the timeout generous for slow networks.
      timeout = 10000,
    },
    config = function(_, opts)
      require("octo").setup(opts)

      -- Teach treesitter that `octo` buffers are markdown. Octo's own
      -- after/syntax/octo.vim already borrows markdown syntax; this is what
      -- lets render-markdown.nvim parse and render them.
      vim.treesitter.language.register("markdown", "octo")

      -- Octo sets octo_diff_props.path *after* the buffer exists and relies on
      -- its own `filetype detect` (lua/octo/reviews/file-entry.lua:360) to pick
      -- up the language, so no autocmd is needed here. Verified: a review diff
      -- buffer named octo://.../file/RIGHT/src/solver.ts resolves to
      -- ft=typescript via vim.filetype.match on the octo name itself.
    end,
  },
}
