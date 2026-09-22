return {
  "tollefj/local-fim.nvim",
  event = "VimEnter",
  config = function(_, opts)
    local fim = require("local-fim")
    fim.setup({
      endpoint = "http://127.0.0.1:8012",
      profile = "qwen2.5-coder-1.5b",
      keymaps = {
        trigger = "<C-G>",    -- Trigger completion with Ctrl+G
        dismiss = false,      -- Disable dismiss keymap
        accept = false,       -- Disable built-in accept (conflicts with cmp)
      },
      model_dir = "/Users/emchap4/.cache/huggingface/hub/models--Qwen--Qwen2.5-Coder-1.5B-Instruct-GGUF/snapshots/f86cb2c1fa58255f8052cc32aeede1b7482d4361",
      profiles = {
        ["qwen2.5-coder-1.5b"] = {
          mode = "infill",
          top_p = 0.7,
          temperature = 0.5,
          stop = { "<|endoftext|>", "<|fim_pad|>", "<|file_sep|>", "<|repo_name|>" },
          server = {
            -- Use relative filename, with model_dir set above
            gguf = "qwen2.5-coder-1.5b-instruct-q4_k_m.gguf",
            ctx = 2048,          -- Context window size (increased to handle prefix+suffix+max_extra_tokens)
            n_gpu_layers = 0,    -- GPU layers (0 = CPU only, 35+ for Metal GPU)
            n_batch = 32,        -- Batch size
          },
        },
      },
    })
    
    -- Ensure the llama-server is running
    require("local-fim.server").ensure(fim.config)
    
    -- Smart Tab: cmp (deterministic) > local-fim (LLM)
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    
    vim.keymap.set("i", "<Tab>", function()
      -- Priority 1: Snippet expansion/jump
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      -- Priority 2: cmp menu is open, select next item
      elseif cmp.visible() then
        cmp.select_next_item()
      -- Priority 3: local-fim has a suggestion, accept it
      elseif fim.has_suggestion() then
        vim.schedule(function()
          fim.accept()
        end)
      -- Fallback: Insert tab
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", false)
      end
    end, { noremap = true, silent = true })
    
    -- Shift+Tab: cmp previous or snippet jump backward
    vim.keymap.set("i", "<S-Tab>", function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      elseif cmp.visible() then
        cmp.select_prev_item()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true), "n", false)
      end
    end, { noremap = true, silent = true })
  end,
}
