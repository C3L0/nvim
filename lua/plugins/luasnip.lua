return{
    {
	"L3MON4D3/LuaSnip",
	config = function()
	    require("luasnip.loaders.from_vscode").lazy_load()
	    -- Add LaTeX-specific snippets
	    require("luasnip").filetype_extend("tex", {"latex"})
	end,
    },
}
