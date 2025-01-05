-- export PRPLEXITY_API_KEY in ~/.bashrc
return {
	"frankroeder/parrot.nvim",
	dependencies = {
		"ibhagwan/fzf-lua",
		"nvim-lua/plenary.nvim",
	},
	cond = os.getenv("PERPLEXITY_API_KEY") ~= nil,
	config = function()
		require("parrot").setup({
			providers = {
				pplx = {
					api_key = os.getenv("PERPLEXITY_API_KEY"),
				},
			},
			-- You can add more configuration options here
		})
	end,
	-- Optional: Add key bindings
	keys = {
		{ "<leader>pc", "<cmd>PrtChatNew<cr>", desc = "New Parrot Chat" },
		{ "<leader>pe", "<cmd>PrtChatToggle<cr>", desc = "Toggle Parrot Chat" },
	},
}
