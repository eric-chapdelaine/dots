return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = nil, -- Disable default <C-\> mapping
				hide_numbers = true,
				start_in_insert = true,
				persist_mode = true,
				close_on_exit = true,
				auto_scroll = true,
				direction = "horizontal",
				size = function(term)
					if term.direction == "horizontal" then
						return math.floor(vim.o.lines * 0.3) -- 30% of screen height
					elseif term.direction == "vertical" then
						return math.floor(vim.o.columns * 0.4)
					end
				end,
			})

			-- Terminal mode keymaps for easy navigation
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

			-- Helper function to toggle a specific terminal ID in horizontal mode
			local function toggle_num(id)
				return function()
					vim.cmd(id .. "ToggleTerm direction=horizontal")
				end
			end

			-- Mappings for Terminal 1 (both tt and t1)
			vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_num(1), { desc = "Toggle Terminal 1" })
			vim.keymap.set({ "n", "t" }, "<leader>t1", toggle_num(1), { desc = "Toggle Terminal 1" })

			-- Mappings for Terminal 2
			vim.keymap.set({ "n", "t" }, "<leader>t2", toggle_num(2), { desc = "Toggle Terminal 2" })

			-- Mappings for Terminal 3
			vim.keymap.set({ "n", "t" }, "<leader>t3", toggle_num(3), { desc = "Toggle Terminal 3" })
		end,
	},
}
