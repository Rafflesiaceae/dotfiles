require("nvim-treesitter.configs").setup({
	ensure_installed = { "nu" },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
