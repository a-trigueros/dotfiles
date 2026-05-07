return {
	{
		"olimorris/codecompanion.nvim",

		opts = {
			strategies = {
				chat = {
					adapter = {
						name = "opencode",
					},
				},
				inline = {
					adapter = {
						name = "opencode",
					},
				},
			},

			extensions = {
				history = {
					enabled = true,
				},
			},
		},

		keys = {
			{
				"<leader>aa",
				"<cmd>CodeCompanionChat Toggle<cr>",
				desc = "AI Chat",
			},

			{
				"<leader>ac",
				"<cmd>CodeCompanionActions<cr>",
				desc = "AI Actions",
			},
			{
				"<leader>as",
				":'<,'>CodeCompanionChat Add<cr>",
				mode = "v",
				desc = "Send selection to chat",
			},
		},
	},
}
