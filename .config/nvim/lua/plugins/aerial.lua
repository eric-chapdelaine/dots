return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {}, -- Lazy will automatically call setup(opts)
	keys = {
		{ "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
	},
}
