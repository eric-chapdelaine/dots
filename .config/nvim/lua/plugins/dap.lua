return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		config = function()
			local dap = require("dap")

			vim.keymap.set("n", "<leader>dc", function()
				dap.continue()
			end)
			vim.keymap.set("n", "<leader>dn", function()
				dap.step_over()
			end)
			vim.keymap.set("n", "<leader>di", function()
				dap.step_into()
			end)
			vim.keymap.set("n", "<leader>do", function()
				dap.step_out()
			end)
			vim.keymap.set("n", "<leader>dt", function()
				dap.terminate()
			end)
			vim.keymap.set("n", "<leader>db", function()
				dap.toggle_breakpoint()
			end)
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end)
			vim.keymap.set("n", "<leader>dr", function()
				dap.repl.open()
			end)
			vim.keymap.set("n", "<leader>du", function()
				require("dap-view").toggle()
			end)
			vim.keymap.set("n", "<leader>da", function()
				dap.attach({ request = "attach", type = "python", connect = { host = "localhost", port = 5678 } })
			end)
		end,
	},
	{
		"igorlfs/nvim-dap-view",
		lazy = false,
		opts = {},
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-python").setup("python")
		end,
	},
}
