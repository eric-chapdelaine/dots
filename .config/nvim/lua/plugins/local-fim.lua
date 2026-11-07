return {
  "tollefj/local-fim.nvim",
  event = "VimEnter",
  config = function()
    -- Machine-local feature: requires a local llama-server and a downloaded GGUF.
    -- Skip silently when the model isn't present (e.g. on the other machine).
    local model_dir = vim.fn.expand(
      "~/.cache/huggingface/hub/models--Qwen--Qwen2.5-Coder-1.5B-Instruct-GGUF/snapshots/f86cb2c1fa58255f8052cc32aeede1b7482d4361"
    )
    if vim.fn.isdirectory(model_dir) == 0 then
      return
    end

    local fim = require("local-fim")
    fim.setup({
      endpoint = "http://127.0.0.1:8012",
      profile = "qwen2.5-coder-1.5b",
      keymaps = {
        trigger = false,      -- Ctrl+G is mapped below so it can start the server first
        dismiss = false,      -- Disable dismiss keymap
        accept = false,       -- Disable built-in accept (conflicts with cmp)
      },
      model_dir = model_dir,
      profiles = {
        ["qwen2.5-coder-1.5b"] = {
          mode = "infill",
          top_p = 0.7,
          temperature = 0.5,
          stop = { "<|endoftext|>", "<|fim_pad|>", "<|file_sep|>", "<|repo_name|>" },
          server = {
            -- Use relative filename, with model_dir set above
            gguf = "qwen2.5-coder-1.5b-instruct-q4_k_m.gguf",
            ctx = 2048,          -- Context window size (prefix + suffix + max_extra_tokens)
            n_gpu_layers = 0,    -- GPU layers (0 = CPU only, 35+ for Metal GPU)
            n_batch = 32,        -- Batch size
          },
        },
      },
    })

    -- Start llama-server on demand instead of at VimEnter, so the confirm
    -- popup only appears when a completion is actually requested.
    local server = require("local-fim.server")

    local function server_up(cb)
      vim.system(
        { "curl", "-s", "--max-time", "1", fim.config.endpoint .. "/health" },
        { text = true },
        vim.schedule_wrap(function(res)
          cb(res.code == 0 and res.stdout ~= nil and res.stdout ~= "")
        end)
      )
    end

    -- llama-server needs a moment to load the model; retry until it answers.
    local function complete_when_ready(attempts)
      server_up(function(up)
        if up then
          if vim.fn.mode():sub(1, 1) == "i" then
            fim.complete()
          end
        elseif attempts > 0 then
          vim.defer_fn(function()
            complete_when_ready(attempts - 1)
          end, 250)
        else
          vim.notify("local-fim: llama-server did not come up in time", vim.log.levels.WARN)
        end
      end)
    end

    local function trigger()
      if vim.fn.executable("curl") == 0 then
        fim.complete()
        return
      end
      server_up(function(up)
        if up then
          fim.complete()
          return
        end
        local choice = vim.fn.confirm(
          ("local-fim: llama-server not running at %s.\nStart %s in the background?"):format(
            fim.config.endpoint,
            fim.config.profile
          ),
          "&Yes\n&No\n&Change profile",
          1
        )
        if choice == 1 then
          server.start(fim.config)
          complete_when_ready(60) -- ~15s
        elseif choice == 3 then
          fim.choose_profile()
        end
      end)
    end

    vim.keymap.set("i", "<C-G>", trigger, { desc = "local-fim: start llama-server if needed, then complete" })

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
