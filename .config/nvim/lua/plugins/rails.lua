return {
  -- Rails-aware navigation: :A, :Econtroller, :Emodel, :Espec, :Eroutes, etc.
  { "tpope/vim-rails" },

  -- Run RSpec (and other test frameworks) from within Neovim
  {
    "vim-test/vim-test",
    dependencies = { "akinsho/toggleterm.nvim" },
    config = function()
      -- Use toggleterm terminal 1 (the horizontal split) to run tests
      vim.g["test#strategy"] = "toggleterm"
      vim.g["test#toggleterm#terminal_id"] = 1

      -- Run rspec inside the Rails Docker container
      vim.g["test#ruby#rspec#executable"] = "docker compose exec rails bundle exec rspec"

      -- <leader>r prefix for Rails/RSpec test commands
      vim.keymap.set("n", "<leader>rn", ":TestNearest<CR>", { desc = "RSpec: run nearest test" })
      vim.keymap.set("n", "<leader>rf", ":TestFile<CR>",    { desc = "RSpec: run test file" })
      vim.keymap.set("n", "<leader>rl", ":TestLast<CR>",    { desc = "RSpec: re-run last test" })
      vim.keymap.set("n", "<leader>rs", ":TestSuite<CR>",   { desc = "RSpec: run full suite" })
    end,
  },
}
