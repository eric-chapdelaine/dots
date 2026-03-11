return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		config = function()
			local dap = require("dap")

		vim.keymap.set("n", "<leader>dc", function()
			dap.continue()
		end)
		vim.keymap.set("n", "<F6>", function()
			dap.continue()
		end, { desc = "DAP: Continue" })
		vim.keymap.set("n", "<leader>dn", function()
			dap.step_over()
		end)
		vim.keymap.set("n", "<F7>", function()
			dap.step_over()
		end, { desc = "DAP: Step Over (Next)" })
		vim.keymap.set("n", "<leader>di", function()
			dap.step_into()
		end)
		vim.keymap.set("n", "<F8>", function()
			dap.step_into()
		end, { desc = "DAP: Step Into" })
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

		-- Node.js / TypeScript (DSE docker container on port 9229)
		-- vscode-js-debug translates DAP (nvim-dap) <-> CDP (Node --inspect)
		local js_debug = vim.fn.expand("~/.local/share/nvim/dap/vscode-js-debug/js-debug/src/dapDebugServer.js")

		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = { js_debug, "${port}" },
			},
		}

		dap.configurations.typescript = {
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to DSE (docker :9229)",
				address = function()
					return vim.fn.input("Host [localhost]: ", "localhost")
				end,
				port = function()
					return tonumber(vim.fn.input("Port [9229]: ", "9229"))
				end,
				localRoot = vim.fn.getcwd(),
				remoteRoot = "/home/node/app",
				sourceMaps = true,
				resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
				skipFiles = { "<node_internals>/**", "**/node_modules/**" },
			},
		}
		dap.configurations.javascript = dap.configurations.typescript
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
