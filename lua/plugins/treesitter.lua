return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
	local configs = require("nvim-treesitter.configs")
	configs.setup({
	    highlight = {
		enable = true,
	    },
	    indent = { enable = true },
	    autotage = { enable = true },
	    ensure_installed = {
		-- A list of parser names, or "all" (the listed parsers MUST always be installed)
		"lua",
		"c",
		-- "python",
		"ninja",
		"rst",
	    }, auto_install = false,
	})
    end
}
